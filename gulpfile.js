'use strict';

var
	c          = require('colors/safe'),
	gulp       = require('gulp'),
	del        = require('del'),
	livescript = require('gulp-livescript'),
	watch      = require('gulp-watch'),
	plumber    = require('gulp-plumber'),
	gutil      = require('gulp-util'),
	sourcemaps = require('gulp-sourcemaps'),
	rename     = require('gulp-rename'),
	stylus     = require('gulp-stylus'),
	uglify     = require('gulp-uglify'),
	argv       = require('yargs').argv,
	bower      = require('gulp-bower'),
	nib        = require('nib'),
	Stream     = require('stream'),
	spawnSync  = require('child_process').spawnSync,
	wrap       = require('gulp-wrap'),
	browSync   = require('browser-sync'),
	browReload = browSync.reload,
	yamlLoad   = require('js-yaml').safeLoad,
	path       = require('path'),
	fs         = require('fs');

var plumberOpts = {
	errorHanlder: function (err) {
		console.error(c.red('Error:'), err.stack || err);
		this.emit('end');
	}
};

function getNewTransformator(transformCb) {
	var stream = new Stream.Transform({ objectMode: true });
	stream._transform = transformCb;
	return stream;
}

function getFileNameWithoutExt(filepath) {
	var
		dirname  = path.dirname(filepath),
		extname  = path.extname(filepath),
		basename = path.basename(filepath, extname);
	return path.join(dirname, basename);
}

// build queue (hardcode for prevent build stuck)

var buildQ = {};

function qPre(logName) {
	
	if ( ! buildQ[logName]) {
		buildQ[logName] = [];
	}
}

/**
 * we can have only 2 tasks in queue
 * 1 - for current building
 * 2 - for building after current
 *
 * @param {string} logName
 * @param {string} filePath
 * @private
 * @returns {number}
 */
function qCnt(logName, id) {
	
	qPre(logName);
	
	return buildQ[logName].reduce(function (count, next) {
		return next.id === id ? ++count : count;
	}, 0);
}

function qAdd(logName) {
	
	qPre(logName);
	var getCount = qCnt.bind(null, logName);
	
	return getNewTransformator(function (file, unused, cb) {
		
		var id = getFileNameWithoutExt(file.relative);
		
		var map = {
			0: function () {
				// queue is completely empty for this file
				// continue building immidiately
				gutil.log(
					c.blue(logName + ': start queue task immidiately for file'),
					id
				);
				buildQ[logName].push({
					id : id,
					fd : file,
					cb : null,
				});
				cb(null, file);
			},
			//1: function () {
			//	// queue can get only more 1 task to queue
			//	// for delayed file building
			//	gutil.log(
			//		c.yellow(logName + ': building is delayed for file'),
			//		id
			//	);
			//	buildQ[logName].push({
			//		id : id,
			//		fd : file,
			//		cb : cb,
			//	});
			//},
			otherwise: function () {
				// queue is full
				// just skip and wait for delayer file building
				// that already in queue
				cb(new Error("File '"+ id +"' is already in building queue"));
			}
		}, f = map[ getCount(id) ];
		f ? f() : map.otherwise();
	});
}

function qEnd(logName) {
	
	qPre(logName);
	
	return getNewTransformator(function (file, unused, cb) {
		
		var
			id = getFileNameWithoutExt(file.relative),
			found = null;
		
		function find(item, i) {
			return item.id === id ? (found = i, true) : false;
		}
		
		buildQ[logName].some(find);
		if (found === null) {
			return cb(new Error('Unexpected shit!'));
		}
		
		buildQ[logName].splice(found, 1);
		gutil.log(
			c.green(logName + ': queue building is complete for file'),
			id
		);
		
		found = null;
		buildQ[logName].some(find);
		if (found !== null) {
			gutil.log(
				c.yellow(logName + ': continue delayed building for file'),
				buildQ[logName][found].id
			);
			(function (params) {
				process.nextTick(function () {
					params.cb(null, params.fd);
				});
			})(['cb', 'fd'].reduce(function (obj, key) {
				obj[key] = buildQ[logName][found][key];
				if (key === 'cb') {
					buildQ[logName][found][key] = null;
				}
				return obj;
			}, {}));
		}
		
		cb(null, file);
	});
}

function qClr(logName) {
	
	qPre(logName);
	
	gutil.log(
		c.red(logName + ' canceling delayed files to build because of error')
	);
	
	buildQ[logName].forEach(function (item) {
		if (item.cb) {
			gutil.log(
				c.red(logName + ' canceling delayed building for file'),
				item.id
			);
			item.cb(new Error('Canceled because of error'));
		}
	});
	
	buildQ[logName] = [];
}

// build helpers

function buildStart(logName) {
	
	if ( ! argv.buildLog) return gutil.noop();
	
	return rename(function (f) {
		gutil.log(
			c.blue(logName + ': building file'),
			path.join(f.dirname, f.basename + f.extname)
		);
	});
}

function buildFinish(logName) {
	
	if ( ! argv.buildLog) return gutil.noop();
	
	return rename(function (f) {
		gutil.log(
			c.green(logName + ': file is builded'),
			path.join(f.dirname, f.basename + f.extname)
		);
	});
}

var REVISION = (function () {
	
	var res = spawnSync('git', ['rev-parse', 'HEAD']);
	
	if (
		res.status !== 0
		|| ! res.stdout
		|| res.stdout.toString().length <= 0
	) {
		throw new Error('Cannot get head git commit id')
	}
	
	return res.stdout.toString().replace(/\s/g, '');
})();


// back-end livescript

gulp.task('clean-server', function (cb) {
	del(['server/build'], cb);
});

function serverTask(isWatcher, cb) {
	
	var logName = 'server';
	
	gulp.src('server/src/**/*.ls')
		.pipe(plumber({
			errorHanlder: function (err) {
				console.error(
					c.red('Error "'+ logName +'":'),
					err.stack || err
				);
				qClr(logName);
				this.emit('end');
			}
		}))
		.pipe(isWatcher ? watch('server/src/**/*.ls') : gutil.noop())
		.pipe(qAdd(logName))
		.pipe(sourcemaps.init())
		.pipe(livescript({ bare: true }))
		.pipe(sourcemaps.write())
		.pipe(gulp.dest('server/build'))
		.pipe(qEnd(logName))
		.on('finish', cb);
}

gulp.task('server', ['clean-server'], serverTask.bind(null, false));
gulp.task('server-watch', ['clean-server'], serverTask.bind(null, true));


// browser sync for front-end

// if we got flag --brow-sync
if (argv.browSync) {
	
	var
		cfgFile = path.resolve(process.cwd(), 'config.yaml'),
		cfg     = yamlLoad(fs.readFileSync(cfgFile, 'utf-8')),
		cfgPort = parseInt(cfg.SERVER.PORT, 10),
		cfgHost = cfg.SERVER.HOST;
	
	gutil.log(
		'Starting browser-sync server at '
		+ c.yellow('http://') + c.blue(cfgHost)
		+ c.yellow(':') + c.blue(cfgPort + 1)
	);
	browSync({
		port  : cfgPort + 1,
		proxy : 'http://'+ cfgHost +':'+ cfgPort,
	});
}

// front-end styles

gulp.task('clean-styles', function (cb) {
	del(['static/css/build'], cb);
});

gulp.task('styles', ['clean-styles'], function (cb) {
	
	gulp.src('front-end-src/styles/main.styl')
		.pipe(plumber(plumberOpts))
		.pipe(buildStart('styles'))
		.pipe( ! argv.min ? sourcemaps.init() : gutil.noop())
		.pipe(stylus({
			compress: argv.min ? true : false,
			use: [
				nib(),
				function (style) {
					style.define('REVISION', REVISION);
					style.define('STATIC_DIR', '/static/');
				},
			],
		}))
		.pipe( ! argv.min ? sourcemaps.write() : gutil.noop())
		.pipe(buildFinish('styles'))
		.pipe(gulp.dest('static/css/build'))
		.pipe(argv.browSync ? browReload({ stream: true }) : gutil.noop())
		.on('finish', cb);
});

gulp.task('styles-watch', ['styles'], function () {
	gulp.watch('front-end-src/styles/**/*.styl', ['styles']);
});


// front-end scripts

gulp.task('clean-scripts', function (cb) {
	del(['static/js/build'], cb);
});

function scriptsTask(isWatcher, cb) {
	
	var logName = 'scripts';
	
	gulp.src('front-end-src/scripts/**/*.ls')
		.pipe(plumber({
			errorHanlder: function (err) {
				console.error(
					c.red('Error "'+ logName +'":'),
					err.stack || err
				);
				qClr(logName);
				this.emit('end');
				return true;
			}
		}))
		.pipe(isWatcher ? watch('front-end-src/scripts/**/*.ls') : gutil.noop())
		.pipe(qAdd(logName))
		.pipe( ! argv.min ? sourcemaps.init() : gutil.noop())
		.pipe(livescript({ bare: true }))
		.pipe(argv.min ? uglify({ preserveComments: 'some' }) : gutil.noop())
		.pipe( ! argv.min ? sourcemaps.write() : gutil.noop())
		.pipe(gulp.dest('static/js/build'))
		.pipe(qEnd(logName))
		.pipe(argv.browSync ? browReload({ stream: true }) : gutil.noop())
		.on('finish', cb);
}

gulp.task('scripts', ['clean-scripts'], scriptsTask.bind(null, false));
gulp.task('scripts-watch', ['clean-scripts'], scriptsTask.bind(null, true));


// minified require.js

gulp.task('clean-requirejs', function (cb) {
	del(['static/js/require.min.js'], cb);
});

gulp.task('requirejs', ['clean-requirejs'], function (cb) {
	
	gulp.src('static/js/require.js')
		.pipe(uglify({ preserveComments: 'some' }))
		.pipe(rename(function (f) { f.basename += '.min'; }))
		.pipe(gulp.dest('static/js'))
		.on('end', cb);
});


// bower

gulp.task('clean-bower', function (cb) {
	del([
		'static/bower',
		'bower_components',
	], cb);
});

gulp.task('bower', ['clean-bower'], function (cb) {
	
	bower()
		.pipe(gulp.dest('static/bower'))
		.on('end', cb);
});

gulp.task('bower-watch', function () {
	gulp.watch('bower.json', ['bower']);
});


// master clean tasks

gulp.task('clean', [
	'clean-server',
	'clean-styles',
	'clean-scripts',
]);

// clean all builded and deploy stuff
gulp.task('distclean', [
	'clean',
	'clean-bower',
], function (cb) {
	del(['node_modules'], cb);
});


// main tasks

gulp.task('watch', [
	'server-watch',
	'styles-watch',
	'scripts-watch',
	'bower-watch',
]);

gulp.task('deploy', [
	'requirejs',
	'bower',
]);

gulp.task('default', [
	'server',
	'styles',
	'scripts',
]);
