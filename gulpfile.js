'use strict';

var
	c           = require('colors/safe'),
	gulp        = require('gulp'),
	watch       = require('gulp-watch'),
	gutil       = require('gulp-util'),
	PluginError = gutil.PluginError,
	rename      = require('gulp-rename'),
	stylus      = require('gulp-stylus'),
	argv        = require('yargs').argv,
	bower       = require('gulp-bower'),
	nib         = require('nib'),
	browSync    = require('browser-sync'),
	browReload  = browSync.reload,
	yamlLoad    = require('js-yaml').safeLoad,
	path        = require('path'),
	fs          = require('fs'),
	glivescript = require('gulp-livescript'),
	uglify      = require('gulp-uglify'),
	sourcemaps  = require('gulp-sourcemaps'),
	vfsFake     = require('vinyl-fs-fake'),
	through2    = require('through2'),
	
	utils       = require('./deploy-stuff/utils');

var
	getFileNameWithoutExt = utils.getFileNameWithoutExt,
	watcherErrorHandler   = utils.watcherErrorHandler,
	itemErrorHandler      = utils.itemErrorHandler,
	buildStart            = utils.buildStart,
	buildFinish           = utils.buildFinish,
	REVISION              = utils.REVISION,
	del                   = utils.del;


// back-end livescript

gulp.task('clean-server', function (cb) {
	del(['server/build'], cb);
});

function serverItemHandler(logName, file, enc, cb) {
	
	vfsFake.src([ file ])
		.pipe(buildStart(logName))
		.pipe(sourcemaps.init())
		.pipe(glivescript({
			bare   : true,
			header : true,
			const  : false,
		}))
		.on('error', function (err) {
			itemErrorHandler.call(this, logName, file, err);
		})
		.pipe(sourcemaps.write())
		.pipe(gulp.dest('server/build'))
		.pipe(buildFinish(logName))
		.on('finish', cb);
}

function serverTask(logName, isWatcher, cb) {
	
	gulp.src('server/src/**/*.ls')
		.pipe(isWatcher ? watch('server/src/**/*.ls') : gutil.noop())
		.on('error', function (err) {
			watcherErrorHandler.call(this, logName, err);
		})
		.pipe(through2.obj(function (file, enc, cb) {
			serverItemHandler.call(this, logName, file, enc, cb);
		}))
		.on('finish', cb);
}

gulp.task('server', ['clean-server'], serverTask.bind(null, 'server', false));
gulp.task('server-watch', ['clean-server'], serverTask.bind(null, 'server', true));


// browser sync for front-end

// if we got flag --browser-sync
if (argv.browserSync) {
	
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

function stylesItemHandler(logName, file, enc, cb) {
	
	vfsFake.src([ file ])
		.pipe(buildStart(logName))
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
		.on('error', function (err) {
			itemErrorHandler.call(this, logName, file, err);
		})
		.pipe( ! argv.min ? sourcemaps.write() : gutil.noop())
		.pipe(gulp.dest('static/css/build'))
		.pipe(argv.browserSync ? browReload({ stream: true }) : gutil.noop())
		.pipe(buildFinish(logName))
		.on('finish', cb);
}

gulp.task('styles', ['clean-styles'], function (cb) {
	
	gulp.src('front-end-src/styles/main.styl')
		.pipe(through2.obj(function (file, enc, cb) {
			stylesItemHandler.call(this, 'styles', file, enc, cb);
		}))
		.on('finish', cb);
});

gulp.task('styles-watch', ['styles'], function () {
	gulp.watch('front-end-src/styles/**/*.styl', ['styles']);
});


// front-end scripts

gulp.task('clean-scripts', function (cb) {
	del(['static/js/build'], cb);
});

function scriptsItemHandler(logName, file, enc, cb) {
	
	vfsFake.src([ file ])
		.pipe(buildStart(logName))
		.pipe( ! argv.min ? sourcemaps.init() : gutil.noop())
		.pipe(glivescript({
			bare   : true,
			header : true,
			const  : false,
		}))
		.on('error', function (err) {
			itemErrorHandler.call(this, logName, file, err);
		})
		.pipe(argv.min ? uglify({ preserveComments: 'some' }) : gutil.noop())
		.pipe( ! argv.min ? sourcemaps.write() : gutil.noop())
		.pipe(gulp.dest('static/js/build'))
		.pipe(argv.browserSync ? browReload({ stream: true }) : gutil.noop())
		.pipe(buildFinish(logName))
		.on('finish', cb);
}

function scriptsTask(logName, isWatcher, cb) {
	
	gulp.src('front-end-src/scripts/**/*.ls')
		.pipe(isWatcher ? watch('front-end-src/scripts/**/*.ls') : gutil.noop())
		.on('error', function (err) {
			watcherErrorHandler.call(this, logName, err);
		})
		.pipe(through2.obj(function (file, enc, cb) {
			scriptsItemHandler.call(this, logName, file, enc, cb);
		}))
		.on('finish', cb);
}

gulp.task('scripts', ['clean-scripts'], scriptsTask.bind(null, 'scripts', false));
gulp.task('scripts-watch', ['clean-scripts'], scriptsTask.bind(null, 'scripts', true));


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
