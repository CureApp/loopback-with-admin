var AdminTokenManager, LoopbackServer, normalize;

normalize = require('path').normalize;

AdminTokenManager = require('../server/admin-token-manager');


/**
launches loopback server

@class LoopbackServer
 */

LoopbackServer = (function() {
  function LoopbackServer() {}

  LoopbackServer.prototype.entryPath = normalize(__dirname + '/../../loopback/server/server.js');


  /**
  @param {Function|Array(String)} [options.fetch] function to return admin tokens (or promise of it). When string[] is given, these value are used for the admin access token.
  @param {Number} [options.intervalHours] Interval hours to fetch new admin token.
   */

  LoopbackServer.prototype.launch = function(adminTokenOptions) {
    if (adminTokenOptions == null) {
      adminTokenOptions = {};
    }
    return new Promise((function(_this) {
      return function(resolve, reject) {
        _this.app = require(_this.entryPath);
        _this.app.lwaTokenManager = new AdminTokenManager(adminTokenOptions);
        return _this.app.start(function(err) {
          var intervalHours;
          console.log("err");
          console.log(err);
          if (err) {
            return reject(err);
          }
          _this.startRefreshingAdminTokens(intervalHours = Number(adminTokenOptions.intervalHours) || 12);
          return resolve();
        });
      };
    })(this));
  };


  /**
  Start refreshing admin access tokens
  
  @public
  @method startRefreshingAdminTokens
  @param {Number} [intervalHours=12]
   */

  LoopbackServer.prototype.startRefreshingAdminTokens = function(intervalHours) {
    if (intervalHours == null) {
      intervalHours = 12;
    }
    console.log("Admin token will be refreshed every " + intervalHours + " hours.");
    if (this.timer != null) {
      clearInterval(this.timer);
    }
    return this.timer = setInterval((function(_this) {
      return function() {
        return _this.app.lwaTokenManager.refreshTokens();
      };
    })(this), intervalHours * 3600 * 1000);
  };


  /**
  Check if the regular timer refreshing admin access tokens is set
  
  @public
  @method isRefreshingAdminTokens
  @return {Boolean}
   */

  LoopbackServer.prototype.isRefreshingAdminTokens = function() {
    return this.timer != null;
  };


  /**
  Stop refreshing admin access tokens
  
  @public
  @method stopRefreshingAdminTokens
   */

  LoopbackServer.prototype.stopRefreshingAdminTokens = function() {
    console.log("Admin token will no more be refreshed.");
    if (this.timer != null) {
      return clearInterval(this.timer);
    }
  };

  return LoopbackServer;

})();

module.exports = LoopbackServer;
