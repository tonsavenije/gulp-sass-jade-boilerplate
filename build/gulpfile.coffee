gulp         = require 'gulp'
parameters   = require '../config/parameters.coffee'

coffee       = require 'gulp-coffee'
concat       = require 'gulp-concat'
gutil        = require 'gulp-util'
jade         = require 'gulp-jade'
sass         = require 'gulp-sass'
bowerFiles   = require 'gulp-main-bower-files'
uglify       = require 'gulp-uglify'

gulp.task 'coffee', ->
	gulp.src parameters.app_path+'/**/*.coffee'
	.pipe coffee bare: true
	.pipe concat parameters.app_main_file
	.pipe gulp.dest parameters.web_path+'/js'
	.on 'error', gutil.log

gulp.task 'jade', ->
	gulp.src parameters.app_path + '/*.jade'
	.pipe jade pretty: true
	.pipe gulp.dest parameters.web_path
	.on 'error', gutil.log

gulp.task 'sass', ->
	gulp.src parameters.styles_main_file
	.pipe sass()
	.pipe gulp.dest parameters.web_path+'/css'
	.on 'error', gutil.log

gulp.task 'bower', ->
	gulp.src './bower.json'
	.pipe bowerFiles()
	.pipe concat parameters.bower_main_file
	.pipe gulp.dest parameters.web_path+'/js'
	.on 'error', gutil.log

gulp.task 'vendor', ->
    gulp.src parameters.vendor_path+'/**/*.js'
    .pipe concat parameters.vendor_main_file
    .pipe gulp.dest parameters.web_path+'/js'
    .on 'error', gutil.log
	
gulp.task 'minify',
	['vendor', 'bower', 'coffee'], ->
		gulp.src parameters.web_path+'/js/**.js'
		.pipe uglify outSourceMap: true
		.pipe gulp.dest parameters.web_path+'js'
		.on 'error', gutil.log

gulp.task 'assets', ->
	gulp.src parameters.assets_path + '/**'
	.pipe gulp.dest parameters.web_path
	.on 'error', gutil.log
	
serve = require 'gulp-serve'

gulp.task 'watch', ['build'], -> # After all build tasks are done
		gulp.watch parameters.app_path + '/**/*.coffee', ['coffee' ]
		gulp.watch parameters.app_path + '/**/*.(less|saas)', ['styles', 'manifest', 'references'] # Manifest and references task is necessary if these files are versioned
		gulp.watch parameters.app_path + '/*.jade', ['jade'] # 'preferences' References task only for files that contain references (but are not versioned, typically index.(jade|html))
		gulp.watch parameters.app_path + '/*/**/*.jade', ['templates']
		gulp.watch parameters.assets_path, ['assets']
		gulp.watch 'bower.json', ['vendors']

gulp.task 'serve', ['build'], serve parameters.web_path

gulp.task 'build', ['sass', 'jade', 'coffee', 'bower', 'vendor']

gulp.task 'default', ->
	