____ = require('debug')('loopback-with-admin:admin-token-manager')

ADMIN_USER =
    email: 'loopback-with-admin@example.com'
    id: 'loopback-with-admin-user-id'
    password: 'admin-user-password' # No worry, noone can login through REST API.

ONE_YEAR = 60 * 60 * 24 * 365

DEFAULT_TOKEN = 'loopback-with-admin-token'

promisify = (fn) ->
    new Promise (y, n) =>
        cb = (e, o) => if e? then n(e) else y(o)
        fn(cb)


class AdminTokenManager

    ###*
    @param {Function|String} [options.fetchNew] function to return new admin token (or promise of it). When string is given, the value is used for the admin access token. Default value is 'loopback-with-admin-access-token'
    @param {Function|Array(String)} [options.fetchAll] function to return initial admin tokens (or promise of it). When string[] is given, these value are used for the admin access token.
    @param {Number} [options.intervalHours] Interval hours to fetch new admin token.
    @param {Number} [options.maxTokens] The limit of the number of admin access tokens. Default is the length of the result of fetchAll()
    ###
    constructor: (options = {}) ->

        { @fetchNew, @fetchAll, @intervalHours, @maxTokens } = options

        if not @fetchNew? or typeof @fetchNew isnt 'function'
            tokenStr = @fetchNew?.toString() ? DEFAULT_TOKEN
            @fetchNew = -> Promise.resolve(tokenStr)

        if typeof @fetchAll isnt 'function'
            @fetchAll = ->
                Promise.resolve @fetchNew()
                .then (tokenStr) -> [tokenStr]

        @tokens = []



    init: (@models) ->

        @createAdminUser()

        .then =>
            @createAdminRole()

        .then =>
            @fetchAll()

        .then (tokenStrs) =>

            ____("tokens: #{tokenStrs.join(',')}")

            Promise.all(
                for tokenStr in tokenStrs
                    token = new AdminToken(tokenStr)
                    @setNew(token)
            )
            .then =>
                ____("tokens are created.")
                ____(@tokens.map((t) -> t.id).join(','))
                return @tokens.slice()


    createAdminUser: ->
        ____("creating admin user. id: #{ADMIN_USER.id}")
        { User } = @models

        promisify (cb) =>
            User.create ADMIN_USER, cb


    createAdminRole: ->

        ____("creating admin role.")
        { Role, RoleMapping } = @models

        promisify (cb) =>
            Role.create name: 'admin', cb

        .then (role) =>
            principal =
                principalType: RoleMapping.USER
                principalId: ADMIN_USER.id

            promisify (cb) =>
                role.principals.create principal, cb



    update: ->

        Promise.resolve @fetchNew()

        .then (tokenStr) =>
            token = new AdminToken(tokenStr)
            @setNew(token)

        .then (succeeded) =>
            @deleteOldest() if succeeded



    setNew: (token) ->

        { AccessToken } = @models

        @exists(token).then (exists) =>

            ____("token: #{token.id} already exists.") if exists
            return false if exists

            ____("saving token: #{token.id}")
            promisify (cb) =>
                AccessToken.create token, cb

            .then (savedToken) =>
                @tokens.push savedToken
                return true



    exists: (token) ->

        { AccessToken } = @models

        promisify (cb) =>
            AccessToken.exists token.id, cb



    deleteOldest: ->

        { AccessToken } = @models

        token = @tokens[0]

        promisify (cb) =>
            AccessToken.destroyById token.id, cb

        .then =>
            @tokens.shift()




class AdminToken

    constructor: (@id) ->
        @userId = ADMIN_USER.id
        @ttl = ONE_YEAR
        @createdAt = new Date().getTime()



module.exports = AdminTokenManager
