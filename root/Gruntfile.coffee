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

    watch:
      options:
        nospawn: true
      all:
        files: ['Gruntfile.coffee', 'src/**/*.coffee', 'test/**/*.coffee']
        tasks: [
          'coffeelint'
          'coffee_build'{% if (browser) { %}
          'livereload'{% } %}
          'mocha_debug'
        ]

    clean:
      all:
        ['build'])

  grunt.event.on('watch', (action, filepath) ->
    grunt.config('coffeelint.all', [filepath])
    if /\.coffee$/.test(filepath)
      grunt.regarde = changed: ['test.js'])

  grunt.loadNpmTasks('grunt-contrib-watch'){% if (browser) { %}
  grunt.loadNpmTasks('grunt-contrib-livereload'){% } %}
  grunt.loadNpmTasks('grunt-contrib-clean')
  grunt.loadNpmTasks('grunt-coffeelint')
  grunt.loadNpmTasks('grunt-coffee-build')
  grunt.loadNpmTasks('grunt-mocha-debug'){% if (!isPrivate) { %}
  grunt.loadNpmTasks('grunt-release'){% } %}

  grunt.registerTask('build', [
    'coffeelint'
    'coffee_build'
    'mocha_debug'
  ]){% if (!isPrivate) { %}
  grunt.registerTask('publish', ['clean', 'build', 'release']){% }%}

  grunt.registerTask('default', [
    'build'{% if (browser) { %}
    'livereload-start'{% } %}
    'watch'
  ])
