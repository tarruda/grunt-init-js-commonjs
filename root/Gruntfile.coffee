module.exports = (grunt) ->
  grunt.initConfig(
    pkg: grunt.file.readJSON('package.json')
    {% if (coffeescript) { %}
    coffeelint:
      options: grunt.file.readJSON('.coffeelintrc')
    {% } else { %}
    exec_jshint:{% } %}
      all: ['Gruntfile{%= ext %}', 'src/**/*{%= ext %}', 'test/**/*{%= ext %}']
    {% if (browser || coffeescript) { %}
    coffee_build:
      options:
        globalAliases: ['<%= pkg.name %>']
        src: ['src/**/*{%= ext %}', 'test/**/*{%= ext %}']
        main: 'src/index{%= ext %}'{% if (nodejs && coffeescript) { %}
      nodejs:
        options:
          dest: 'build/nodejs'{% } if (browser) { %}
      browser:
        options:
          dest: 'build/browser/tests.js'
      browser_dist:
        options:
          src: 'src/**/*{%= ext %}'
          dest: 'build/browser/<%= pkg.name %>.js'{% } %}
      {% } %}
    mocha_debug:
      options:
        reporter: 'dot'
        check: ['src/**/*{%= ext %}', 'test/**/*{%= ext %}']{% if (nodejs) { %}
      nodejs:
        options:{% if (coffeescript) { %}
          src: ['build/nodejs/**/*.js']{% } else { %}
          src: ['src/**/*.js', 'test/**/*.js']{% } } if (browser) { %}
      browser:
        options:
          listenAddress: '0.0.0.0'
          listenPort: 8000
          phantomjs: true
          src: ['build/browser/tests.js']

    uglify:
      options:
        sourceMapIn: 'build/browser/<%= pkg.name %>.js.map'
        sourceMap: 'build/browser/<%= pkg.name %>.min.js.map'
      files:
        'build/browser/<%= pkg.name %>.min.js':
          ['build/browser/<%= pkg.name %>.js']
    {% } %}
    watch:
      options:
        nospawn: true
      all:
        files: ['Gruntfile{%= ext %}', 'src/**/*{%= ext %}', 'test/**/*{%= ext %}']
        tasks: [
          'test'{% if (browser) { %}
          'livereload'{% } %}
        ]
    {% if (browser || coffeescript) { %}
    clean: ['build']
    {% } %})
  grunt.event.on('watch', (action, filepath) ->
    grunt.regarde = changed: ['test.js'])

  grunt.loadNpmTasks('grunt-contrib-watch'){% if (browser) { %}
  grunt.loadNpmTasks('grunt-contrib-livereload')
  grunt.loadNpmTasks('grunt-contrib-uglify'){% } if (browser || coffeescript) { %}
  grunt.loadNpmTasks('grunt-contrib-clean'){% } %}
  grunt.loadNpmTasks('grunt-{%= coffeescript ? "coffeelint" : "exec-jshint" %}'){% if (browser || coffeescript) { %}
  grunt.loadNpmTasks('grunt-coffee-build'){% } %}
  grunt.loadNpmTasks('grunt-mocha-debug')
  grunt.loadNpmTasks('grunt-newer'){% if (!isPrivate) { %}
  grunt.loadNpmTasks('grunt-release'){% } %}

  grunt.registerTask('test', [
    'newer:{%= coffeescript ? "coffeelint" : "exec_jshint" %}'{% if (browser || coffeescript) { if (nodejs && coffeescript) { %}
    'coffee_build:nodejs'{% } if (browser) { %}
    'coffee_build:browser'{% }} %}
    'mocha_debug'
  ])
  {% if (browser || coffeescript) { %}
  grunt.registerTask('rebuild', [
    'clean'
    'newer:{%= coffeescript ? "coffeelint" : "exec_jshint" %}'
    'coffee_build'
    'mocha_debug'{% if (browser) { %}
    'uglify'{% } %}
  ])
  {% } if (!isPrivate) { %}
  grunt.registerTask('publish', ['{%= (coffeescript || browser) ? "rebuild" : "mocha_debug" %}', 'release'])
  {% } %}
  grunt.registerTask('default', ['test'{% if (browser) { %}, 'livereload-start'{% } %}, 'watch'])
