require('source-map-support').install()
global.expect = require('chai').expect

###
 The object passed to 'run' will be processed similarly to mocha exports
 interface, the difference is that its possible to prefix test/suite names with
 'only:' and 'skip:' to isolate/skip that test/suite.
###

run(
  'Suite':
    before: (done) ->
      @t = require('../src')
      done()


    'test': ->
      expect(@t).to.be.true


    'AsyncSuite':
      'async test': (done) ->
        expect(@t).to.be.true
        done()
)
