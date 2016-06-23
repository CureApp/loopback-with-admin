
AclConditions = require './acl-conditions'

###*
generate ACL
ACL is Array of access control information

@class AclGenerator
###
class AclGenerator

    constructor: (aclType = 'admin', @isUser = false) ->
        @acl = []
        @aclConditions = @constructor.createAclConditions(aclType)


    ###*
    create AclConditions by aclType
    @param {String|Object} aclType
    ###
    @createAclConditions: (aclType) ->

        if typeof aclType is 'string'

            aclTypeStr = aclType

            switch aclTypeStr
                when 'admin'
                    aclType = {}

                when 'owner'
                    aclType = { owner: 'rwx' }

                when 'public-read-by-owner'
                    aclType = { public: 'r', owner: 'rwx' }

                when 'member-read-by-owner'
                    aclType = { member: 'r', owner: 'rwx' }

                when 'member-read'
                    aclType = { member: 'r' }

                when 'public-read'
                    aclType = { public: 'r' }

                when 'none'
                    aclType = { public: 'rwx' }

        return new AclConditions(aclType)


    ###*
    get ACL by aclConditions

    @method generate
    @public
    return {Array} ACL
    ###
    generate: ->

        if @aclConditions.isPublic()
            return @acl

        @commonACL()

        if @aclConditions.isAdminOnly()
            @adminACL()
            return @acl

        @addAllowACL('$everyone',      @aclConditions.basicPermissions.public)
        @addAllowACL('$authenticated', @aclConditions.basicPermissions.member)
        @addAllowACL('$owner',         @aclConditions.basicPermissions.owner)

        for roleName, accessTypes of @aclConditions.customPermissions
            @addAllowACL(roleName, accessTypes, ['create', 'updateAttributes'])

        return @acl


    ###*
    append ACL allowing accesses from the accessToken of model's owners

    @method ownerACL
    @private
    ###
    addAllowACL: (principalId, accessTypes, properties = []) ->

        accessTypes.forEach (accessType) =>
            if properties.length > 0 and accessType is 'WRITE'
                for property in properties
                    @acl.push
                        accessType: accessType
                        principalType: 'ROLE'
                        principalId: principalId
                        permission: 'ALLOW'
                        property: property
            else
                @acl.push
                    accessType: accessType
                    principalType: 'ROLE'
                    principalId: principalId
                    permission: 'ALLOW'



    ###*
    append basic ACL, which allow accesses only from admin

    @method commonACL
    @private
    ###
    commonACL: ->
        # set everyone access denied and admin access allowed
        @acl.push
            accessType: '*'
            principalType: 'ROLE'
            principalId: '$everyone'
            permission: 'DENY'

        @acl.push
            accessType: '*'
            principalType: 'ROLE'
            principalId: 'admin'
            permission: 'ALLOW'

        if @isUser
            @userACL()
        @

    ###*
    append ACL for User model

    @method userACL
    @private
    ###
    userACL: ->
        # admin cannot logout. avoid CSRF attacks which make admin logout.
        @acl.push
            accessType: 'EXECUTE'
            principalType: 'ROLE'
            principalId: 'admin'
            permission: 'DENY'
            property: 'logout'

        # user creation is denied by default.
        @acl.push
            accessType: 'WRITE'
            principalType: 'ROLE'
            principalId: '$everyone'
            permission: 'DENY'
            property: 'create'
        @

        # user creation is allowed by admin.
        @acl.push
            accessType: 'WRITE'
            principalType: 'ROLE'
            principalId: 'admin'
            permission: 'ALLOW'
            property: 'create'
        @


    ###*
    append ACL allowing accesses only from admin

    @method adminACL
    @private
    ###
    adminACL: ->
        if @isUser
            @adminUserACL()


    ###*
    append ACL for User model handled by admin,
    denying login from everyone. Login must be executed via admin access.

    @method adminUserACL
    @private
    ###
    adminUserACL: ->
        # login is denied by default
        @acl.push
            accessType: 'EXECUTE'
            principalType: 'ROLE'
            principalId: '$everyone'
            permission: 'DENY'
            property: 'login'

        @acl.push
            accessType: 'EXECUTE'
            principalType: 'ROLE'
            principalId: 'admin'
            permission: 'ALLOW'
            property: 'login'


module.exports = AclGenerator
