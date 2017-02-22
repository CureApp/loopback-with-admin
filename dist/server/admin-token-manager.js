var AdminToken, AdminTokenManager, DEFAULT_ADMIN_USER, DEFAULT_TOKEN, ONE_YEAR, ____, promisify,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

____ = require('debug')('loopback-with-admin:admin-token-manager');

DEFAULT_ADMIN_USER = {
  email: 'loopback-with-admin@example.com',
  id: 'loopback-with-admin-user-id',
  password: 'admin-user-password'
};

ONE_YEAR = 60 * 60 * 24 * 365;

DEFAULT_TOKEN = 'loopback-with-admin-token';

promisify = function(fn) {
  return new Promise((function(_this) {
    return function(y, n) {
      var cb;
      cb = function(e, o) {
        if (e != null) {
          return n(e);
        } else {
          return y(o);
        }
      };
      return fn(cb);
    };
  })(this));
};


/**
Admin token manager

@class AdminTokenManager
 */

AdminTokenManager = (function() {

  /**
  @param {Function|Array(String)} [options.fetch] function to return admin tokens (or promise of it). When string[] is given, these value are used for the admin access token.
  @param {String} [options.email=loopback-with-admin@example.com] email address for admin user
  @param {String} [options.id=loopback-with-admin-user-id] id of admin user
  @param {String} [options.password=admin-user-password] password of admin user
   */
  function AdminTokenManager(options) {
    var email, fetch, id, password;
    if (options == null) {
      options = {};
    }
    fetch = options.fetch, email = options.email, id = options.id, password = options.password;
    this.fetch = this.constructor.createFetchFunction(fetch);
    this.adminUser = {
      email: email || DEFAULT_ADMIN_USER.email,
      id: id || DEFAULT_ADMIN_USER.id,
      password: password || DEFAULT_ADMIN_USER.password
    };
    this.tokensById = {};
  }


  /**
  Set fetched tokens as admin tokens.
  
  @public
  @method init
  @param {Object} models app.models in LoopBack
  @return {Promise}
   */

  AdminTokenManager.prototype.init = function(models) {
    this.models = models;
    return this.createAdminUser().then((function(_this) {
      return function() {
        return _this.createAdminRole();
      };
    })(this)).then((function(_this) {
      return function() {
        return _this.fetch();
      };
    })(this)).then((function(_this) {
      return function(tokenStrs) {
        if (!_this.validTokenStrs(tokenStrs)) {
          throw _this.invalidTokenError(tokenStrs);
        }
        return _this.updateTokens(tokenStrs);
      };
    })(this));
  };


  /**
  Refresh admin tokens.
  
  @public
  @method refreshTokens
  @return {Promise}
   */

  AdminTokenManager.prototype.refreshTokens = function() {
    return this.fetch().then((function(_this) {
      return function(tokenStrs) {
        if (!_this.validTokenStrs(tokenStrs)) {
          console.error("AdminTokenManager: Fetched tokens are not valid!\n\nResults: " + tokenStrs + "\n");
          return Promise.resolve(false);
        }
        return _this.updateTokens(tokenStrs);
      };
    })(this));
  };


  /**
  Get current tokens
  @public
  @method getCurrentTokens
  @return {Array(String)}
   */

  AdminTokenManager.prototype.getCurrentTokens = function() {
    return Object.keys(this.tokensById);
  };


  /**
  Save new tokens and destroy old tokens.
  @private
   */

  AdminTokenManager.prototype.updateTokens = function(tokenStrs) {
    var tokens;
    tokens = tokenStrs.map((function(_this) {
      return function(tokenStr) {
        return new AdminToken(tokenStr, _this.adminUser.id);
      };
    })(this));
    return Promise.all(tokens.map((function(_this) {
      return function(token) {
        return _this.setNew(token);
      };
    })(this))).then((function(_this) {
      return function() {
        var promises, tokenStr;
        promises = [];
        for (tokenStr in _this.tokensById) {
          if (indexOf.call(tokenStrs, tokenStr) < 0) {
            promises.push(_this.destroy(tokenStr));
          }
        }
        return Promise.all(promises);
      };
    })(this)).then((function(_this) {
      return function() {
        return ____("tokens: " + (Object.keys(_this.tokensById).join(',')));
      };
    })(this));
  };


  /**
  set new token
  @private
   */

  AdminTokenManager.prototype.setNew = function(token) {
    var AccessToken;
    AccessToken = this.models.AccessToken;
    return this.findById(token.id).then((function(_this) {
      return function(foundToken) {
        if (foundToken != null) {
          ____("token: " + token.id + " already exists.");
          if (foundToken.userId !== _this.adminUser.id) {
            console.error("AdminTokenManager: The token `" + token.id + "` is already exist for non-admin user. Skip creating.");
            console.error();
          }
          return false;
        }
        ____("saving token: " + token.id);
        return promisify(function(cb) {
          return AccessToken.create(token, cb);
        }).then(function() {
          return true;
        });
      };
    })(this)).then((function(_this) {
      return function(tokenIsSavedNow) {
        return _this.tokensById[token.id] = token;
      };
    })(this));
  };


  /**
  Destroy the token
  @private
   */

  AdminTokenManager.prototype.destroy = function(tokenStr) {
    return this.findById(tokenStr).then((function(_this) {
      return function(foundToken) {
        var AccessToken;
        if (foundToken.userId !== _this.adminUser.id) {
          console.error("AdminTokenManager: The token `" + token.id + "` is not the admin token. Skip destroying.");
          return false;
        }
        AccessToken = _this.models.AccessToken;
        return promisify(function(cb) {
          return AccessToken.destroyById(tokenStr, cb);
        }).then(function() {
          return delete _this.tokensById[tokenStr];
        });
      };
    })(this));
  };


  /**
  Find AccessToken model by tokenStr
  @private
   */

  AdminTokenManager.prototype.findById = function(tokenStr) {
    var AccessToken;
    AccessToken = this.models.AccessToken;
    return promisify((function(_this) {
      return function(cb) {
        return AccessToken.findById(tokenStr, cb);
      };
    })(this));
  };


  /**
  Create admin user, called once in 'init' function.
  @private
   */

  AdminTokenManager.prototype.createAdminUser = function() {
    var User;
    ____("creating admin user. id: " + this.adminUser.id);
    User = this.models.User;
    return promisify((function(_this) {
      return function(cb) {
        return User.create(_this.adminUser, cb);
      };
    })(this));
  };


  /**
  Create admin role, called once in 'init' function.
  @private
   */

  AdminTokenManager.prototype.createAdminRole = function() {
    var Role, RoleMapping, ref;
    ____("creating admin role.");
    ref = this.models, Role = ref.Role, RoleMapping = ref.RoleMapping;
    return promisify((function(_this) {
      return function(cb) {
        return Role.create({
          name: 'admin'
        }, cb);
      };
    })(this)).then((function(_this) {
      return function(role) {
        var principal;
        principal = {
          principalType: RoleMapping.USER,
          principalId: _this.adminUser.id
        };
        return promisify(function(cb) {
          return role.principals.create(principal, cb);
        });
      };
    })(this));
  };


  /**
  Check the fetched results are valid
  @private
   */

  AdminTokenManager.prototype.validTokenStrs = function(tokenStrs) {
    return Array.isArray(tokenStrs) && tokenStrs.length > 0 && tokenStrs.every(function(v) {
      return typeof v === 'string';
    });
  };


  /**
  Create an error to indicate the tokenStrs are invalid
  @private
   */

  AdminTokenManager.prototype.invalidTokenError = function(tokenStrs) {
    return new Error("AdminTokenManager could not fetch valid access tokens.\nResult: '" + tokenStrs + "'\nCheck if the valid function is passed to the 3rd arugment of run() method.\n\n    var fn = function() {\n        return Promise.resolve(['token1', 'token2', 'token3'])\n    };\n\n    require('loopback-with-admin').run(models, config, { admin: {fetch: fn} })");
  };


  /**
  Create valid fetch function
  @private
  @static
   */

  AdminTokenManager.createFetchFunction = function(fetch) {
    if (fetch == null) {
      return (function(_this) {
        return function() {
          return Promise.resolve([DEFAULT_TOKEN]);
        };
      })(this);
    }
    if (typeof fetch === 'string') {
      return (function(_this) {
        return function() {
          return Promise.resolve([fetch]);
        };
      })(this);
    }
    if (Array.isArray(fetch)) {
      return (function(_this) {
        return function() {
          return Promise.resolve(fetch.slice());
        };
      })(this);
    }
    if (typeof fetch !== 'function') {
      return (function(_this) {
        return function() {
          return Promise.resolve([DEFAULT_TOKEN]);
        };
      })(this);
    }
    return (function(_this) {
      return function() {
        return Promise.resolve(fetch()).then(function(results) {
          if (typeof results === 'string') {
            return [results];
          }
          if (Array.isArray(results)) {
            return results;
          }
          return [];
        });
      };
    })(this);
  };

  return AdminTokenManager;

})();


/**
Admin token

@class AdminToken
@private
 */

AdminToken = (function() {
  function AdminToken(id1, userId) {
    this.id = id1;
    this.userId = userId;
    this.ttl = ONE_YEAR;
    this.isAdmin = true;
  }

  return AdminToken;

})();

module.exports = AdminTokenManager;
