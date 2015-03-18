fs = require 'fs'

module.exports = (grunt) ->

  require('time-grunt')(grunt)
  require('load-grunt-tasks')(grunt)

  grunt.initConfig
    twigRender:
      compile:
        options:
          extensions: [
            (Twig) ->
              oldLoad = Twig.Templates.loadRemote
              Twig.Templates.loadRemote = (location, params, callback, error_callback) ->
                if(!fs.existsSync(location))
                  location = 'src/' + location
                oldLoad(location, params, callback, error_callback)
          ]
        files:[
          data: 'src/data.json'
          expand: true
          cwd: 'src'
          src: ['**/*.twig', '!**/_*.twig']
          dest: 'build'
          ext: '.html'
        ]
    connect:
      options:
        port: 9000
        open: true
        livereload: 35729
        hostname: 'localhost'
      livereload:
        options:
          middleware: (connect) ->
            return [
              require('connect-livereload')(),
              connect.static('build')
            ]
    watch:
      options:
        livereload: true
      twig:
        files: ['src/**/*.twig', 'src/**/*.json']
        tasks: ['twigRender']
      livereload:
        options:
          livereload: '<%= connect.options.livereload %>'
        files: [
          'src/**.*'
        ]

  grunt.registerTask 'serve', (target) ->
    grunt.task.run([
      'twigRender'
      'connect:livereload',
      'watch'
    ])