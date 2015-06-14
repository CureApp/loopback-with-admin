

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

        switch aclType

            when 'admin'
                @adminACL()

            when 'owner'
                @ownerACL()

            when 'public-read'
                @publicReadACL()

            else
                throw new Error """unknown aclType: #{aclType}"""

        return @acl


    ###*
    append ACL allowing accesses only from admin

    @method adminACL
    @private
    ###
    adminACL: ->
        @commonACL()

        if @isUser
            @adminUserACL()
        @


    ###*
    append ACL allowing accesses from the accessToken of model's owners

    @method ownerACL
    @private
    ###
    ownerACL: ->

        @commonACL()

        accessTypes = ['READ', 'WRITE', 'EXECUTE']

        for accessType in accessTypes
            @acl.push
                accessType: accessType
                principalType: 'ROLE'
                principalId: '$owner'
                permission: 'ALLOW'
        @

    ###*
    append ACL allowing accesses from READ access to everyone

    @method publicReadACL
    @private
    ###
    publicReadACL: ->
        @commonACL()
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
