assert = require('assert')

for k, v of assert
  global[k] = v

{% if (browser || coffeescript) { %}require('source-map-support').install(){% } %}

###
 The object passed to 'runMocha' will be processed similarly to mocha exports
 interface, the difference is that its possible to prefix test/suite names with
 'only:' and 'skip:' to isolate/skip that test/suite.
###

runMocha(
  'Suite':
    before: (done) ->
      @t = require('../src')
      done()


    'test': ->
      ok(@t)


    'AsyncSuite':
      'async test': (done) ->
        ok(@t)
        done()
)
