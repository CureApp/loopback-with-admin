var AclConditions, AclGenerator;

AclConditions = require('./acl-conditions');


/**
generate ACL
ACL is Array of access control information

@class AclGenerator
 */

AclGenerator = (function() {
  function AclGenerator(aclType, isUser) {
    if (aclType == null) {
      aclType = 'admin';
    }
    this.isUser = isUser != null ? isUser : false;
    this.acl = [];
    this.aclConditions = this.constructor.createAclConditions(aclType);
  }


  /**
  create AclConditions by aclType
  @param {String|Object} aclType
   */

  AclGenerator.createAclConditions = function(aclType) {
    var aclTypeStr;
    if (typeof aclType === 'string') {
      aclTypeStr = aclType;
      switch (aclTypeStr) {
        case 'admin':
          aclType = {};
          break;
        case 'owner':
          aclType = {
            owner: 'rwx'
          };
          break;
        case 'public-read-by-owner':
          aclType = {
            "public": 'r',
            owner: 'rwx'
          };
          break;
        case 'member-read-by-owner':
          aclType = {
            member: 'r',
            owner: 'rwx'
          };
          break;
        case 'member-read':
          aclType = {
            member: 'r'
          };
          break;
        case 'public-read':
          aclType = {
            "public": 'r'
          };
          break;
        case 'none':
          aclType = {
            "public": 'rwx'
          };
      }
    }
    return new AclConditions(aclType);
  };


  /**
  get ACL by aclConditions
  
  @method generate
  @public
  return {Array} ACL
   */

  AclGenerator.prototype.generate = function() {
    var accessTypes, ref, roleName;
    if (this.aclConditions.isPublic()) {
      return this.acl;
    }
    this.commonACL();
    if (this.aclConditions.isAdminOnly()) {
      this.adminACL();
      return this.acl;
    }
    this.addAllowACL('$everyone', this.aclConditions.basicPermissions["public"]);
    this.addAllowACL('$authenticated', this.aclConditions.basicPermissions.member);
    this.addAllowACL('$owner', this.aclConditions.basicPermissions.owner);
    ref = this.aclConditions.customPermissions;
    for (roleName in ref) {
      accessTypes = ref[roleName];
      this.addAllowACL(roleName, accessTypes, ['create', 'updateAttributes']);
    }
    return this.acl;
  };


  /**
  append ACL allowing accesses from the accessToken of model's owners
  
  @method ownerACL
  @private
   */

  AclGenerator.prototype.addAllowACL = function(principalId, accessTypes, properties) {
    if (properties == null) {
      properties = [];
    }
    return accessTypes.forEach((function(_this) {
      return function(accessType) {
        var i, len, property, results;
        if (properties.length > 0 && accessType === 'WRITE') {
          results = [];
          for (i = 0, len = properties.length; i < len; i++) {
            property = properties[i];
            results.push(_this.acl.push({
              accessType: accessType,
              principalType: 'ROLE',
              principalId: principalId,
              permission: 'ALLOW',
              property: property
            }));
          }
          return results;
        } else {
          return _this.acl.push({
            accessType: accessType,
            principalType: 'ROLE',
            principalId: principalId,
            permission: 'ALLOW'
          });
        }
      };
    })(this));
  };


  /**
  append basic ACL, which allow accesses only from admin
  
  @method commonACL
  @private
   */

  AclGenerator.prototype.commonACL = function() {
    this.acl.push({
      accessType: '*',
      principalType: 'ROLE',
      principalId: '$everyone',
      permission: 'DENY'
    });
    this.acl.push({
      accessType: '*',
      principalType: 'ROLE',
      principalId: 'admin',
      permission: 'ALLOW'
    });
    if (this.isUser) {
      this.userACL();
    }
    return this;
  };


  /**
  append ACL for User model
  
  @method userACL
  @private
   */

  AclGenerator.prototype.userACL = function() {
    this.acl.push({
      accessType: 'EXECUTE',
      principalType: 'ROLE',
      principalId: 'admin',
      permission: 'DENY',
      property: 'logout'
    });
    this.acl.push({
      accessType: 'WRITE',
      principalType: 'ROLE',
      principalId: '$everyone',
      permission: 'DENY',
      property: 'create'
    });
    this;
    this.acl.push({
      accessType: 'WRITE',
      principalType: 'ROLE',
      principalId: 'admin',
      permission: 'ALLOW',
      property: 'create'
    });
    return this;
  };


  /**
  append ACL allowing accesses only from admin
  
  @method adminACL
  @private
   */

  AclGenerator.prototype.adminACL = function() {
    if (this.isUser) {
      return this.adminUserACL();
    }
  };


  /**
  append ACL for User model handled by admin,
  denying login from everyone. Login must be executed via admin access.
  
  @method adminUserACL
  @private
   */

  AclGenerator.prototype.adminUserACL = function() {
    this.acl.push({
      accessType: 'EXECUTE',
      principalType: 'ROLE',
      principalId: '$everyone',
      permission: 'DENY',
      property: 'login'
    });
    return this.acl.push({
      accessType: 'EXECUTE',
      principalType: 'ROLE',
      principalId: 'admin',
      permission: 'ALLOW',
      property: 'login'
    });
  };

  return AclGenerator;

})();

module.exports = AclGenerator;
