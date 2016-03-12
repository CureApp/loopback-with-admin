
/**
Loopback info

@class LoopbackInfo
 */
var LoopbackInfo;

LoopbackInfo = (function() {
  function LoopbackInfo(server, generatedInMain) {
    if (server == null) {
      server = {};
    }
    if (generatedInMain == null) {
      generatedInMain = {};
    }
    if (typeof server.kill === 'function') {
      this.process = server;
    } else {
      this.app = server;
    }
    this.config = generatedInMain.config, this.models = generatedInMain.models, this.buildInfo = generatedInMain.buildInfo, this.bootInfo = generatedInMain.bootInfo;
  }


  /**
  get hosting URL
  
  @method getURL
  @public
  @param {String} [hostName]
  @return {String} url
   */

  LoopbackInfo.prototype.getURL = function(hostName) {
    if (hostName == null) {
      hostName = this.config.server.host;
    }
    return hostName + ":" + this.config.server.port + this.config.server.restApiRoot;
  };


  /**
  get environment
  
  @method getEnv
  @public
  @return {String} env
   */

  LoopbackInfo.prototype.getEnv = function() {
    return this.buildInfo.env;
  };


  /**
  get access token of admin
  
  @method getAccessToken
  @public
  return {String}
   */

  LoopbackInfo.prototype.getAccessToken = function() {
    return this.config.admin.accessToken;
  };


  /**
  kill loopback process
  
  @method kill
  @public
   */

  LoopbackInfo.prototype.kill = function() {
    var ref;
    return (ref = this.process) != null ? ref.kill() : void 0;
  };

  return LoopbackInfo;

})();

module.exports = LoopbackInfo;
