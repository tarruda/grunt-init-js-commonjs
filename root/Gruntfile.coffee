require('js-yaml')


module.exports = (grunt) ->
  grunt.initConfig(
    pkg: grunt.file.readJSON('package.json')

    coffeelint:
      options: require('./.coffeelint.yml')
      all: ['Gruntfile.coffee', 'src/**/*.coffee', 'test/**/*.coffee']

    coffee_build:
      options:
        globalAliases: ['<%= pkg.name %>']
        src: ['src/**/*.coffee', 'test/**/*.coffee']
        main: 'src/index.coffee'{% if (nodejs) { %}
      nodejs:
        options:
          dest: 'build/nodejs'{% } %}{% if (browser) { %}
      browser:
        options:
          dest: 'build/browser/test.js'
      browser_release:
        options:
          src: 'src/**/*.coffee'
          dest: 'build/browser/<%= pkg.name %>.js'{% } %}

    mocha_debug:
      options:
        reporter: 'dot'
        check: ['src/**/*.coffee', 'test/**/*.coffee']{% if (nodejs) { %}
      nodejs:
        options:
          src: ['build/nodejs/**/*.js']{% } %}{% if (browser) { %}
      browser:
        options:
          listenAddress: '0.0.0.0'
          listenPort: 8000
          phantomjs: true
          src: ['build/browser/test.js']{% } %}
    {% if (browser) { %}
    uglify:
      options:
        sourceMap: 'build/browser/<%= pkg.name %>.min.js.map'
        sourceMapIn: 'build/browser/<%= pkg.name %>.js.map'
      files:
        src: 'build/browser/<%= pkg.name %>.js'
        dest: 'build/browser/<%= pkg.name %>.min.js'
    {% } %}
    watch:
      options:
        nospawn: true
      all:
        files: ['Gruntfile.coffee', 'src/**/*.coffee', 'test/**/*.coffee']
        tasks: [
          'test'{% if (browser) { %}
          'livereload'{% } %}
        ]

    clean: ['build'])

  grunt.event.on('watch', (action, filepath) ->
    grunt.config('coffeelint.all', [filepath])
    if /\.coffee$/.test(filepath)
      grunt.regarde = changed: ['test.js'])

  grunt.loadNpmTasks('grunt-contrib-watch'){% if (browser) { %}
  grunt.loadNpmTasks('grunt-contrib-livereload')
  grunt.loadNpmTasks('grunt-contrib-uglify'){% } %}
  grunt.loadNpmTasks('grunt-contrib-clean')
  grunt.loadNpmTasks('grunt-coffeelint')
  grunt.loadNpmTasks('grunt-coffee-build')
  grunt.loadNpmTasks('grunt-mocha-debug'){% if (!isPrivate) { %}
  grunt.loadNpmTasks('grunt-release'){% } %}

  grunt.registerTask('test', [
    'coffeelint'{% if (nodejs) { %}
    'coffee_build:nodejs'{% } %}{% if (browser) { %}
    'coffee_build:browser'{% } %}
    'mocha_debug'
  ])

  grunt.registerTask('rebuild', [
    'clean'
    'coffeelint'
    'coffee_build'
    'mocha_debug'{% if (browser) { %}
    'uglify'{% } %}
  ])
  {% if (!isPrivate) { %}
  grunt.registerTask('publish', ['rebuild', 'release'])
  {% }%}
  grunt.registerTask('default', ['test'{% if (browser) { %}, 'livereload-start'{% } %}, 'watch'])
