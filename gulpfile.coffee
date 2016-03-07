gulp       = require 'gulp'
coffee     = require 'gulp-coffee'
yuidoc     = require 'gulp-yuidoc'


gulp.task 'coffee', ->

    gulp.src 'src/**/*.coffee'
        .pipe(coffee bare: true)
        .pipe(gulp.dest 'dist')


gulp.task 'yuidoc', ->

    gulp.src 'src/**/*.coffee'
        .pipe(yuidoc({
            syntaxtype: 'coffee'
            project:
                name: 'loopback-with-admin'
        }))
        .pipe(gulp.dest('doc'))
        .on('error', console.log)

module.exports = gulp
