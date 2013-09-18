require('source-map-support').install()
global.expect = require('chai').expect

t = require('../src')

# The 'suite' object will be processed and run as a mocha suite like mocha
# exports interface, the difference is that its possible to prefix test/suite
# names with 'only:' and 'skip:' to have the same effect as
# {it,describe}.{only,skip}.

suite =
  'Suite':
    before: (done) ->
      @t = t
      done()


    'test': ->
      expect(@t).to.be.true


    'AsyncSuite':
      'async test': (done) ->
        expect(@t).to.be.true
        done()


run(suite)
