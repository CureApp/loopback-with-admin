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

    constructor: (@app, @fetchNew, @fetchAll) ->

        # in this timing, @app is incomplete: it doesn't contain models' information.
        # `init` will be called after @app is built.

        if not @fetchNew? or typeof @fetchNew isnt 'function'
            tokenStr = @fetchNew?.toString() ? DEFAULT_TOKEN
            @fetchNew = -> Promise.resolve(tokenStr)

        if typeof @fetchAll isnt 'function'
            @fetchAll = ->
                Promise.resolve @fetchNew()
                .then (tokenStr) -> [tokenStr]

        @tokens = []



    init: ->

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
        { User } = @app.models

        promisify (cb) =>
            User.create ADMIN_USER, cb


    createAdminRole: ->

        ____("creating admin role.")
        { Role, RoleMapping } = @app.models

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

        { AccessToken } = @app.models

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

        { AccessToken } = @app.models

        promisify (cb) =>
            AccessToken.exists token.id, cb



    deleteOldest: ->

        { AccessToken } = @app.models

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
