var AclConditions,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

AclConditions = (function() {

  /**
  basic names
  @static
   */
  AclConditions.basicNames = ['public', 'member', 'owner'];


  /**
  get array of ['READ', 'WRITE', 'EXECUTE']
  
  @method regularPermissions
  @static
  @param {String} rwx characters sequence 'r w x' meaning READ, WRITE, EXECUTE
  @param {Object} flags if flags.r is on, remove READ, and so the others.
  @return {Array(String)}
   */

  AclConditions.regularPermissions = function(rwx, flags) {
    var permissions;
    if (rwx == null) {
      rwx = '';
    }
    if (flags == null) {
      flags = {};
    }
    permissions = {
      r: 'READ',
      w: 'WRITE',
      x: 'EXECUTE'
    };
    return rwx.split('').filter(function(c) {
      return !flags[c];
    }).filter(function(c) {
      return permissions[c];
    }).map(function(c) {
      flags[c] = true;
      return permissions[c];
    });
  };

  function AclConditions(aclType) {
    var flags, i, len, name, ref, rwx;
    if (aclType == null) {
      aclType = {};
    }
    this.basicPermissions = {};
    this.customPermissions = {};
    flags = {
      r: false,
      w: false,
      x: false
    };
    ref = this.constructor.basicNames;
    for (i = 0, len = ref.length; i < len; i++) {
      name = ref[i];
      rwx = aclType[name];
      this.basicPermissions[name] = this.constructor.regularPermissions(rwx, flags);
    }
    for (name in aclType) {
      rwx = aclType[name];
      if (indexOf.call(this.constructor.basicNames, name) < 0) {
        this.customPermissions[name] = this.constructor.regularPermissions(rwx);
      }
    }
  }

  AclConditions.prototype.isPublic = function() {
    var ref;
    return ((ref = this.basicPermissions["public"]) != null ? ref.length : void 0) === 3;
  };

  AclConditions.prototype.isAdminOnly = function() {
    var name, ref, regularPermissions;
    if (Object.keys(this.customPermissions).length > 0) {
      return false;
    }
    ref = this.basicPermissions;
    for (name in ref) {
      regularPermissions = ref[name];
      if (regularPermissions.length > 0) {
        return false;
      }
    }
    return true;
  };

  return AclConditions;

})();

module.exports = AclConditions;
