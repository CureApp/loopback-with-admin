var LoopbackServer, normalize;

normalize = require('path').normalize;


/**
launches loopback server

@class LoopbackServer
 */

LoopbackServer = (function() {
  function LoopbackServer() {}

  LoopbackServer.prototype.entryPath = normalize(__dirname + '/../../loopback/server/server.js');

  LoopbackServer.prototype.launch = function() {
    return new Promise((function(_this) {
      return function(resolve) {
        return require(_this.entryPath).start(resolve);
      };
    })(this));
  };

  return LoopbackServer;

})();

module.exports = LoopbackServer;
