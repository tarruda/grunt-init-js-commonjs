module.exports = (grunt) ->
  grunt.initConfig(
    pkg: grunt.file.readJSON('package.json')

    exec_jshint:
      all: ['lib/**/*.js', 'test/**/*.js']

    powerbuild:
      options:
        sourceMap: true
      test:
        files: [
          {src: 'test/**/*.js', dest: 'build/test.js'}
        ]

    mocha_debug:
      options:
        reporter: 'dot'
        check: ['lib/**/*.js', 'test/**/*.js']
      nodejs:
        options:
          src: ['lib/**/*.js', 'test/**/*.js']
      browser:
        options:
          listenAddress: '0.0.0.0'
          listenPort: 8000
          phantomjs: true
          src: ['build/test.js']

    watch:
      options:
        nospawn: true
      all:
        files: ['Gruntfile.coffee', 'lib/**/*.js', 'test/**/*.js']
        tasks: [
          'test'
          'livereload'
        ]

    clean: ['build']

  grunt.event.on('watch', (action, filepath) ->
    grunt.regarde = changed: ['test.js'])

  grunt.loadNpmTasks('powerbuild')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-contrib-livereload')
  grunt.loadNpmTasks('grunt-contrib-clean')
  grunt.loadNpmTasks('grunt-mocha-debug')
  grunt.loadNpmTasks('grunt-newer')
  grunt.loadNpmTasks('grunt-release')
  grunt.loadNpmTasks('grunt-exec-jshint')

  grunt.registerTask('test', [
    'newer:exec_jshint'
    'powerbuild'
    'mocha_debug'
  ])

  grunt.registerTask('rebuild', [
    'clean'
    'newer:exec_jshint'
    'powerbuild'
    'mocha_debug'
  ])
  {% if (!isPrivate) { %}
  grunt.registerTask('publish', ['rebuild', 'release']){% } %}
  grunt.registerTask('default', ['test', 'livereload-start', 'watch'])
