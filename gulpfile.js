var gulp = require('gulp'),
    g    = require('gulp-load-plugins')();

gulp.task('build', function{
  gulp.src('./src/**/*.coffee')
    .pipe(g.concat('node-file.js', {newLine: '\r\n'}))
    .pipe(g.coffee({bare: true}).on('error', g.util.log))
    .pipe(g.wrap(['var fs = require("fs");',
      'var path = require("path");',
      'var eventproxy = require("eventproxy");',
      '<%= contents %>'].join('\r\n')))
    .pipe(gulp.dest('./lib'));
});

gulp.task('default', ['build']);
