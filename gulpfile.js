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
	path       = require('path'),
	stylus     = require('gulp-stylus'),
	uglify     = require('gulp-uglify'),
	argv       = require('yargs').argv,
	bower      = require('gulp-bower'),
	nib        = require('nib'),
	spawnSync  = require('child_process').spawnSync,
	wrap       = require('gulp-wrap'),
	
	plumberOpts = {
		errorHanlder: function (err) {
			console.error(c.red('Error:'), err.stack || err);
			this.emit('end');
		}
	};

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
	
	gulp.src('server/src/**/*.ls')
		.pipe(isWatcher ? watch('server/src/**/*.ls') : gutil.noop())
		.pipe(plumber(plumberOpts))
		.pipe(buildStart('server'))
		.pipe(sourcemaps.init())
		.pipe(livescript({ bare: true }))
		.pipe(sourcemaps.write())
		.pipe(buildFinish('server'))
		.pipe(gulp.dest('server/build'))
		.on('finish', cb);
}

gulp.task('server', ['clean-server'], serverTask.bind(null, false));
gulp.task('server-watch', ['clean-server'], serverTask.bind(null, true));


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
			compress : !!argv.min,
			use      : [
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
	
	gulp.src('front-end-src/scripts/**/*.ls')
		.pipe(isWatcher ? watch('front-end-src/scripts/**/*.ls') : gutil.noop())
		.pipe(plumber(plumberOpts))
		.pipe(buildStart('scripts'))
		.pipe( ! argv.min ? sourcemaps.init() : gutil.noop())
		.pipe(livescript({ bare: true }))
		.pipe(argv.min ? uglify({ preserveComments: 'some' }) : gutil.noop())
		.pipe( ! argv.min ? sourcemaps.write() : gutil.noop())
		.pipe(buildFinish('scripts'))
		.pipe(gulp.dest('static/js/build'))
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


// prelude-ls

gulp.task('clean-prelude', function (cb) {
	del(['static/js/prelude/build'], cb);
});

gulp.task('prelude-amd', ['clean-prelude'], function (cb) {
	
	gulp.src('static/js/prelude/src/*.js')
		.pipe(wrap([
			"define(['module'], function (module) {",
			'<%= contents %>',
			'});',
		].join('\n\n')))
		.pipe(gulp.dest('static/js/prelude/build'))
		.on('end', cb);
});

gulp.task('prelude-min', ['prelude-amd'], function (cb) {
	
	gulp.src([
		'static/js/prelude/build/*.js',
		'!static/js/prelude/build/*.min.js',
	])
		.pipe(uglify({ preserveComments: 'some' }))
		.pipe(rename(function (f) { f.basename += '.min'; }))
		.pipe(gulp.dest('static/js/prelude/build'))
		.on('end', cb);
});

gulp.task('prelude', ['prelude-min']);


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
	'clean-prelude',
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
	'prelude',
	'bower',
]);

gulp.task('default', [
	'server',
	'styles',
	'scripts',
]);
