
class AclConditions

    ###*
    basic names
    @static
    ###
    @basicNames: ['public', 'member', 'owner']


    ###*
    get array of ['READ', 'WRITE', 'EXECUTE']

    @method regularPermissions
    @static
    @param {String} rwx characters sequence 'r w x' meaning READ, WRITE, EXECUTE
    @param {Object} flags if flags.r is on, remove READ, and so the others.
    @return {Array(String)}
    ###
    @regularPermissions: (rwx = '', flags = {}) ->

        permissions = { r: 'READ', w: 'WRITE', x: 'EXECUTE' }

        return rwx.split('')
                .filter (c) -> not flags[c]
                .filter (c) -> permissions[c]
                .map (c) ->
                    flags[c] = true
                    return permissions[c]


    constructor: (aclType = {}) ->

        @basicPermissions  = {}
        @customPermissions = {}

        flags = { r: false, w: false, x: false }

        # set basic rwx
        for name in @constructor.basicNames
            rwx = aclType[name]
            @basicPermissions[name] = @constructor.regularPermissions(rwx, flags)

        # set custom rwx
        for name, rwx of aclType when name not in @constructor.basicNames
            @customPermissions[name] = @constructor.regularPermissions(rwx)


    isPublic: ->
        @basicPermissions.public?.length is 3


    isAdminOnly: ->
        return false if Object.keys(@customPermissions).length > 0

        for name, regularPermissions of @basicPermissions
            return false if regularPermissions.length > 0
        return true

    hasCustomWrite: ->
        for name, permissions of @customPermissions
            if isNaN(parseInt(name)) is false
                continue
            if permissions.indexOf('WRITE') isnt -1
                return true
        false

module.exports = AclConditions
