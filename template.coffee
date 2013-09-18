exports.description = 'Scaffold coffeescript commonjs projects'


exports.notes =
  """
  This template will generate a commonjs project with build configurations for
  node.js (possibly other commonjs environments) and/or plain browser load
  through a concatenated umd module. The project may contain coffeescript
  and/or javascript files but it will be scaffolded with a coffeescript project
  in mind.

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
    init.copyAndProcess(files, props)
    init.writePackageJSON('package.json', props, (pkg) =>
      pkg.main = './build/nodejs/src/index'

      if props.isPrivate
        pkg.private = true

      pkg.devDependencies =
        'grunt': '~0.4.1'
        'grunt-contrib-clean': '~0.5.0'
        'grunt-contrib-watch': '~0.5.3'
        'grunt-coffeelint': '~0.0.7'
        'grunt-coffee-build': '~1.4.9'
        'grunt-mocha-debug': '~0.0.6'
        'chai': '~1.7.2'
        'source-map-support': '~0.2.3'
        'js-yaml': '~2.1.0'

      if props.browser
        pkg.devDependencies['grunt-contrib-livereload'] = '~0.1.2'
        pkg.devDependencies['grunt-contrib-uglify'] = '~0.2.4'

      if not props.isPrivate
        pkg.devDependencies['grunt-release'] = '~0.5.1'

      if props.nodejs
        pkg.engines = node: '>= 0.8.0'

      return pkg
    ))
