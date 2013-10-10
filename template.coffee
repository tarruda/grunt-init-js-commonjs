exports.description = 'Scaffold a commonjs project'


exports.notes =
  """
  Generates a commonjs javascript project targeting node.js and web browsers,
  with basic travis/saucelabs configuration and automatic bundling with
  source maps
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
  curly: false
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
  ], (err, props) ->

    files = init.filesToCopy(props)
    init.addLicenseFiles(files, props.licenses)
    init.copyAndProcess(files, props)

    grunt.file.write('.jshintrc', JSON.stringify(jshintDefaults, null, 2))
    grunt.file.write('test/.jshintrc',
      JSON.stringify(jshintTestDefaults, null, 2))

    init.writePackageJSON('package.json', props, (pkg) =>
      pkg.main = './lib/index'

      if props.isPrivate
        pkg.private = true

      pkg.devDependencies =
        'grunt': '~0.4.1'
        'grunt-contrib-clean': '~0.5.0'
        'grunt-contrib-watch': '~0.5.3'
        'grunt-contrib-livereload': '~0.1.2'
        'grunt-mocha-debug': '~0.0.8'
        'grunt-newer': '~0.5.4'
        'powerbuild': '~0.0.9'
        'grunt-saucelabs': '~4.1.2'
        'grunt-exec-jshint': '~0.0.0'

      if not props.isPrivate
        pkg.devDependencies['grunt-release'] = '~0.5.1'

      if props.nodejs
        pkg.engines = node: '>= 0.8.0'

      pkg.scripts = test: 'grunt ci'

      return pkg
    ))
