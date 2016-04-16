
/**
Loopback info

@class LoopbackInfo
 */
var LoopbackInfo;

LoopbackInfo = (function() {
  function LoopbackInfo(lbServer, generatedInMain) {
    this.lbServer = lbServer;
    if (generatedInMain == null) {
      generatedInMain = {};
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
  get available admin access tokens
  
  @method getAdminTokens
  @public
  @return {Array(String)} tokens
   */

  LoopbackInfo.prototype.getAdminTokens = function() {
    return this.lbServer.app.lwaTokenManager.getCurrentTokens();
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

  return LoopbackInfo;

})();

module.exports = LoopbackInfo;
