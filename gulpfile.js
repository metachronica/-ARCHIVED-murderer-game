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

gulp.task('server', ['clean-server'], function (cb) { serverTask(false, cb); });
gulp.task('server-watch', function (cb) { serverTask(true, cb); });


// front-end styles

gulp.task('clean-styles', function (cb) {
	del(['static/css/build'], cb);
});

function stylesTask(isWatcher, cb) {
	
	gulp.src('front-end-src/styles/main.styl')
		.pipe(isWatcher ? watch('front-end-src/styles/**/*.styl') : gutil.noop())
		.pipe(buildStart('styles'))
		.pipe(plumber(plumberOpts))
		.pipe(sourcemaps.init())
		.pipe(stylus({ compress: !!argv.min }))
		.pipe(sourcemaps.write())
		.pipe(buildFinish('styles'))
		.pipe(gulp.dest('static/css/build'))
		.on('finish', cb);
}

gulp.task('styles', ['clean-styles'], function (cb) { stylesTask(false, cb); });
gulp.task('styles-watch', function (cb) { stylesTask(true, cb); });


// front-end scripts

gulp.task('clean-scripts', function (cb) {
	del(['static/js/build'], cb);
});

function scriptsTask(isWatcher, cb) {
	
	gulp.src('front-end-src/scripts/**/*.ls')
		.pipe(isWatcher ? watch('front-end-src/scripts/**/*.ls') : gutil.noop())
		.pipe(buildStart('scripts'))
		.pipe(plumber(plumberOpts))
		.pipe(sourcemaps.init())
		.pipe(livescript({ bare: true }))
		.pipe(argv.min ? uglify({ preserveComments: 'some' }) : gutil.noop())
		.pipe(sourcemaps.write())
		.pipe(buildFinish('scripts'))
		.pipe(gulp.dest('static/js/build'))
		.on('finish', cb);
}

gulp.task('scripts', ['clean-scripts'], function (cb) { scriptsTask(false, cb); });
gulp.task('scripts-watch', function (cb) { scriptsTask(true, cb); });


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


// master clean tasks

gulp.task('clean', [
	'clean-server',
	'clean-styles',
	'clean-scripts',
	'clean-bower',
]);

// clean all builded and deploy stuff
gulp.task('distclean', ['clean'], function (cb) {
	del(['node_modules'], cb);
});


// main tasks

gulp.task('watch', ['server-watch', 'styles-watch', 'scripts-watch']);
gulp.task('default', ['server', 'styles', 'scripts']);
