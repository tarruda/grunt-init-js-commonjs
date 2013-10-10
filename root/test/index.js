assert = require('assert');


for (var k in assert) global[k] = v;


runMocha({
  'Suite': {
    before: function(done) {
      this.t = require('../src');
      done();
    },


    'test': function() {
      ok(this.t);
    },


    'AsyncSuite': {
      'async test': function(done) {
        ok(this.t);
        done();
      }
    }
  }
});
