
/**
generate ACL
ACL is Array of access control information

@class AclGenerator
 */
var AclGenerator;

AclGenerator = (function() {
  function AclGenerator(aclType, isUser) {
    this.aclType = aclType != null ? aclType : 'admin';
    this.isUser = isUser != null ? isUser : false;
    this.acl = [];
  }


  /**
  get ACL by aclType
  
  @method generate
  @public
  @param {String} aclType
  return {Array} ACL
   */

  AclGenerator.prototype.generate = function() {
    switch (this.aclType) {
      case 'admin':
        this.commonACL();
        this.adminACL();
        break;
      case 'owner':
        this.commonACL();
        this.ownerACL();
        break;
      case 'public-read-by-owner':
        this.commonACL();
        this.ownerACL();
        this.publicReadACL();
        break;
      case 'member-read-by-owner':
        this.commonACL();
        this.ownerACL();
        this.memberReadACL();
        break;
      case 'member-read':
        this.commonACL();
        this.memberReadACL();
        break;
      case 'public-read':
        this.commonACL();
        this.publicReadACL();
        break;
      case 'none':
        return this.acl = [];
      default:
        throw new Error("unknown aclType: " + this.aclType);
    }
    return this.acl;
  };


  /**
  append ACL allowing accesses only from admin
  
  @method adminACL
  @private
   */

  AclGenerator.prototype.adminACL = function() {
    if (this.isUser) {
      this.adminUserACL();
    }
    return this;
  };


  /**
  append ACL allowing accesses from the accessToken of model's owners
  
  @method ownerACL
  @private
   */

  AclGenerator.prototype.ownerACL = function() {
    var accessType, accessTypes, i, len;
    accessTypes = ['READ', 'WRITE', 'EXECUTE'];
    for (i = 0, len = accessTypes.length; i < len; i++) {
      accessType = accessTypes[i];
      this.acl.push({
        accessType: accessType,
        principalType: 'ROLE',
        principalId: '$owner',
        permission: 'ALLOW'
      });
    }
    return this;
  };


  /**
  append ACL allowing READ accesses from authenticated users
  
  @method memberReadACL
  @private
   */

  AclGenerator.prototype.memberReadACL = function() {
    this.acl.push({
      accessType: 'READ',
      principalType: 'ROLE',
      principalId: '$authenticated',
      permission: 'ALLOW'
    });
    return this;
  };


  /**
  append ACL allowing accesses from READ access to everyone
  
  @method publicReadACL
  @private
   */

  AclGenerator.prototype.publicReadACL = function() {
    this.acl.push({
      accessType: 'READ',
      principalType: 'ROLE',
      principalId: '$everyone',
      permission: 'ALLOW'
    });
    return this;
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
    return this;
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
    this.acl.push({
      accessType: 'EXECUTE',
      principalType: 'ROLE',
      principalId: 'admin',
      permission: 'ALLOW',
      property: 'login'
    });
    return this;
  };

  return AclGenerator;

})();

module.exports = AclGenerator;
