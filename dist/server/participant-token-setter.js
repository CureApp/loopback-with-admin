var DEFAULT_TOKEN, HUNDRED_YEARS, PARTICIPANT_USER, ParticipantTokenSetter, ____, promisify;

____ = require('debug')('loopback-with-admin:participant-token-setter');

PARTICIPANT_USER = {
  email: 'loopback-with-participant@example.com',
  id: 'loopback-with-admin-participant',
  password: 'participant-user-password'
};

HUNDRED_YEARS = 60 * 60 * 24 * 365 * 100;

DEFAULT_TOKEN = 'loopback-with-admin-participant';

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
Participant token setter

@class ParticipantTokenSetter
 */

ParticipantTokenSetter = (function() {

  /**
  @param {String} token participant token
   */
  function ParticipantTokenSetter(token1) {
    this.token = token1 != null ? token1 : DEFAULT_TOKEN;
  }

  ParticipantTokenSetter.prototype.set = function(models) {
    this.models = models;
    return this.createUser().then((function(_this) {
      return function() {
        return _this.createRole();
      };
    })(this)).then((function(_this) {
      return function() {
        return _this.setToken(_this.token);
      };
    })(this));
  };


  /**
  Create participant user
  @private
   */

  ParticipantTokenSetter.prototype.createUser = function() {
    var User;
    ____("creating participant user. id: " + PARTICIPANT_USER.id);
    User = this.models.User;
    return promisify((function(_this) {
      return function(cb) {
        return User.create(PARTICIPANT_USER, cb);
      };
    })(this));
  };


  /**
  Create participant role
  @private
   */

  ParticipantTokenSetter.prototype.createRole = function() {
    var Role, RoleMapping, ref;
    ____("creating participant role.");
    ref = this.models, Role = ref.Role, RoleMapping = ref.RoleMapping;
    return promisify((function(_this) {
      return function(cb) {
        return Role.create({
          name: 'participant'
        }, cb);
      };
    })(this)).then((function(_this) {
      return function(role) {
        var principal;
        principal = {
          principalType: RoleMapping.USER,
          principalId: PARTICIPANT_USER.id
        };
        return promisify(function(cb) {
          return role.principals.create(principal, cb);
        });
      };
    })(this));
  };


  /**
  set new token
  @private
   */

  ParticipantTokenSetter.prototype.setToken = function(token) {
    var AccessToken;
    AccessToken = this.models.AccessToken;
    return this.findById(token).then((function(_this) {
      return function(foundToken) {
        if (foundToken != null) {
          ____("token: " + token + " already exists.");
          if (foundToken.userId !== PARTICIPANT_USER.id) {
            console.error("ParticipantTokenSetter: The token `" + token + "` is already exist for non-participant user. Skip creating.");
            console.error();
          }
          return false;
        }
        ____("saving token: " + token);
        return promisify(function(cb) {
          return AccessToken.create({
            id: token,
            userId: PARTICIPANT_USER.id,
            ttl: HUNDRED_YEARS
          }, cb);
        }).then(function() {
          return true;
        });
      };
    })(this));
  };


  /**
  Find AccessToken model by tokenStr
  @private
   */

  ParticipantTokenSetter.prototype.findById = function(tokenStr) {
    var AccessToken;
    AccessToken = this.models.AccessToken;
    return promisify((function(_this) {
      return function(cb) {
        return AccessToken.findById(tokenStr, cb);
      };
    })(this));
  };

  return ParticipantTokenSetter;

})();

module.exports = ParticipantTokenSetter;
