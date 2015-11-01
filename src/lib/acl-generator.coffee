

###*
generate ACL
ACL is Array of access control information

@class AclGenerator
###
class AclGenerator

    constructor: (@aclType = 'admin', @isUser = false) ->
        @acl = []


    ###*
    get ACL by aclType

    @method generate
    @public
    @param {String} aclType
    return {Array} ACL
    ###
    generate: ->

        switch @aclType

            when 'admin'
                @commonACL()
                @adminACL()

            when 'owner'
                @commonACL()
                @ownerACL()

            when 'public-read-by-owner'
                @commonACL()
                @ownerACL()
                @publicReadACL()

            when 'member-read-by-owner'
                @commonACL()
                @ownerACL()
                @memberReadACL()

            when 'member-read'
                @commonACL()
                @memberReadACL()

            when 'public-read'
                @commonACL()
                @publicReadACL()

            when 'none'
                return @acl = []

            else
                throw new Error """unknown aclType: #{@aclType}"""

        return @acl


    ###*
    append ACL allowing accesses only from admin

    @method adminACL
    @private
    ###
    adminACL: ->
        if @isUser
            @adminUserACL()
        @


    ###*
    append ACL allowing accesses from the accessToken of model's owners

    @method ownerACL
    @private
    ###
    ownerACL: ->

        accessTypes = ['READ', 'WRITE', 'EXECUTE']

        for accessType in accessTypes
            @acl.push
                accessType: accessType
                principalType: 'ROLE'
                principalId: '$owner'
                permission: 'ALLOW'
        @

    ###*
    append ACL allowing READ accesses from authenticated users

    @method memberReadACL
    @private
    ###
    memberReadACL: ->

        @acl.push
            accessType: 'READ'
            principalType: 'ROLE'
            principalId: '$authenticated'
            permission: 'ALLOW'
        @

    ###*
    append ACL allowing accesses from READ access to everyone

    @method publicReadACL
    @private
    ###
    publicReadACL: ->
        @acl.push
            accessType: 'READ'
            principalType: 'ROLE'
            principalId: '$everyone'
            permission: 'ALLOW'
        @


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
        @



module.exports = AclGenerator
