exports.description = 'Scaffold coffeescript commonjs projects'


exports.notes =
  """
  This template will generate a commonjs project with build configurations for
  node.js (possibly other commonjs environments) and/or plain browser load
  through a concatenated umd module. The project may contain coffeescript
  and/or javascript files but a main language must be chosen for the initally
  scaffolded files.

  The task 'grunt-coffee-build' is used for doing all the build hard work
  such as compiling, generating source maps, browserifying dependencies and
  wrapping in umd. For more information visit the task documentation:
  https://github.com/tarruda/grunt-coffee-build

  The project will be configured with node.js and/or phamtonjs(headless
  browser) testing through the 'grunt-mocha-debug' task. For node.js testing,
  the the task will search files for 'debugger' statements, and if found it
  will start mocha with the '--debug-brk' argument for debugging with
  'node-inspector'.  Visit https://github.com/tarruda/grunt-mocha-debug for
  more info.

  The default grunt task will watch, rebuild and rerun tests when source files
  changes. It will also start a livereload server for automatically reloading
  tests in graphical browsers with a livereload extension.
  """


exports.after =
  """
  Project ready, install the dependencies with 'npm install'
  """


exports.warnOn = '*'


isBoolean = (answer) ->
  answer == 'Y/n' or /^y$/i.test(answer) or answer == 'y/N' or
  /^n$/i.test(answer)


toBoolean = (answer) -> answer == 'Y/n' or /^y$/i.test(answer)


jshintDefaults =
  curly: true
  eqeqeq: true
  immed: true
  latedef: true
  newcap: true
  noarg: true
  sub: true
  undef: true
  boss: true
  eqnull: true
  node: true
  browser: true
  debug: true


jshintTestDefaults =
  globals: expect: false, run: false
  expr: true


coffeelintDefaults =
  arrow_spacing: level: 'error'
  empty_constructor_needs_parens: level: 'error'
  non_empty_constructor_needs_parens: level: 'error'
  no_trailing_whitespace: level: 'error'
  no_empty_param_list: level: 'error'
  no_stand_alone_at: level: 'error'
  no_backticks: level: 'ignore'
  no_implicit_braces: level: 'ignore'
  space_operators: level: 'error'


exports.template = (grunt, init, done) ->
  init.process({}, [
    init.prompt('name')
    init.prompt('description')
    init.prompt('version', '0.0.0')
    init.prompt('repository')
    init.prompt('homepage')
    init.prompt('bugs')
    init.prompt('licenses', 'MIT')
    init.prompt('author_name')
    init.prompt('author_email')
    init.prompt('author_url')
    {
      name: 'coffeescript'
      message: 'Is this a coffeescript project?'
      default: 'Y/n'
      warning: 'Answer y/n'
      validator: isBoolean
      sanitize: (value, data, done) ->
        data.coffeescript = toBoolean(value)
        done()
    }
    {
      name: 'isPrivate'
      message: 'Is this a private project?'
      default: 'y/N'
      warning: 'Answer y/n'
      validator: isBoolean
      sanitize: (value, data, done) ->
        data.isPrivate = toBoolean(value)
        done()
    }
    {
      name: 'nodejs'
      message: 'Will this project target node.js?'
      default: 'Y/n'
      warning: 'Answer y/n'
      validator: isBoolean
      sanitize: (value, data, done) ->
        data.nodejs = toBoolean(value)
        done()
    }
    {
      name: 'browser'
      message: 'Will this project target web browsers?'
      default: 'Y/n'
      warning: 'Answer y/n'
      validator: isBoolean
      sanitize: (value, data, done) ->
        data.browser = toBoolean(value)
        done()
    }
  ], (err, props) ->
    if not (props.browser or props.nodejs)
      throw new Error('Project must target at least one platform')

    files = init.filesToCopy(props)
    init.addLicenseFiles(files, props.licenses)

    if props.coffeescript
      props.ext = '.coffee'
      init.copyAndProcess(files, props)
    else
      props.ext = '.js'
      csext = /\.coffee$/

      # compile using grunt's own version of coffeescript
      for own k, v of require.cache
        if /coffee-script\.js$/.test(k)
          cs = require.cache[k].exports
          break

      # adjust destination
      for own k, v of files
        if csext.test(k)
          newk = k.replace(csext, '.js')
          files[newk] = files[k]
          delete files[k]

      init.copyAndProcess files, props, process: (contents, srcpath) ->
        contents = grunt.template.process(
          contents, data: props, delimiters: 'init')
        if csext.test(srcpath)
          contents = cs.compile(contents, bare: true, header: false)
        return contents

    if props.coffeescript
      grunt.file.write('.coffeelintrc',
        JSON.stringify(coffeelintDefaults, null, 2))
    else
      grunt.file.write('.jshintrc', JSON.stringify(jshintDefaults, null, 2))
      grunt.file.write('test/.jshintrc',
        JSON.stringify(jshintTestDefaults, null, 2))

    init.writePackageJSON('package.json', props, (pkg) =>
      if props.coffeescript
        pkg.main = './build/nodejs/src/index'
      else
        pkg.main = './src/index'

      if props.isPrivate
        pkg.private = true

      pkg.devDependencies =
        'grunt': '~0.4.1'
        'grunt-contrib-watch': '~0.5.3'
        'grunt-mocha-debug': '~0.0.8'
        'grunt-newer': '~0.5.4'

      if props.coffeescript or props.browser
        pkg.devDependencies['grunt-coffee-build'] = '~1.4.9'
        pkg.devDependencies['grunt-contrib-clean'] = '~0.5.0'
        pkg.devDependencies['source-map-support'] = '~0.2.3'

      if props.coffeescript
        pkg.devDependencies['grunt-coffeelint'] = '~0.0.7'
      else
        pkg.devDependencies['grunt-exec-jshint'] = '~0.0.0'

      if props.browser
        pkg.devDependencies['grunt-contrib-livereload'] = '~0.1.2'
        pkg.devDependencies['grunt-contrib-uglify'] = '~0.2.4'

      if not props.isPrivate
        pkg.devDependencies['grunt-release'] = '~0.5.1'

      if props.nodejs
        pkg.engines = node: '>= 0.8.0'

      return pkg
    ))
