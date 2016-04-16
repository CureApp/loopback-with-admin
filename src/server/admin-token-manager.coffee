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


###*
Admin token manager

@class AdminTokenManager
###
class AdminTokenManager

    ###*
    @param {Function|Array(String)} [options.fetch] function to return admin tokens (or promise of it). When string[] is given, these value are used for the admin access token.
    ###
    constructor: (options = {}) ->

        { fetch } = options

        @fetch = @constructor.createFetchFunction(fetch)

        @tokensById = {}



    ###*
    Set fetched tokens as admin tokens.

    @public
    @method init
    @param {Object} models app.models in LoopBack
    @return {Promise}
    ###
    init: (@models) ->

        @createAdminUser()

        .then =>
            @createAdminRole()

        .then =>
            @fetch()

        .then (tokenStrs) =>

            if not @validTokenStrs(tokenStrs)
                throw @invalidTokenError(tokenStrs)

            @updateTokens(tokenStrs)



    ###*
    Refresh admin tokens.

    @public
    @method refreshTokens
    @return {Promise}
    ###
    refreshTokens: ->

        @fetch().then (tokenStrs) =>

            if not @validTokenStrs(tokenStrs)

                console.error("""
                    AdminTokenManager: Fetched tokens are not valid!

                    Results: #{tokenStrs}

                    """)
                return Promise.resolve(false)

            @updateTokens(tokenStrs)


    ###*
    Get current tokens
    @public
    @method getCurrentTokens
    @return {Array(String)}
    ###
    getCurrentTokens: ->
        Object.keys @tokensById


    ###*
    Save new tokens and destroy old tokens.
    @private
    ###
    updateTokens: (tokenStrs) ->

        tokens = tokenStrs.map (tokenStr) -> new AdminToken(tokenStr)

        Promise.all(tokens.map (token) => @setNew token).then =>

            promises = []

            for tokenStr of @tokensById when tokenStr not in tokenStrs
                promises.push @destroy(tokenStr)

            Promise.all promises

        .then =>
            ____("tokens: #{Object.keys(@tokensById).join(',')}")


    ###*
    set new token
    @private
    ###
    setNew: (token) ->

        { AccessToken } = @models

        @findById(token.id).then (foundToken) =>

            if foundToken?
                ____("token: #{token.id} already exists.")

                if foundToken.userId isnt ADMIN_USER.id
                    console.error """
                        AdminTokenManager: The token `#{token.id}` is already exist for non-admin user. Skip creating.
                    """
                    console.error()

                return false

            ____("saving token: #{token.id}")
            promisify (cb) =>
                AccessToken.create token, cb

            .then => true

        .then (tokenIsSavedNow) =>
            @tokensById[token.id] = token



    ###*
    Destroy the token
    @private
    ###
    destroy: (tokenStr) ->

        @findById(tokenStr).then (foundToken) =>
            # check if the token to be deleted is admin token
            if foundToken.userId isnt ADMIN_USER.id
                console.error """
                    AdminTokenManager: The token `#{token.id}` is not the admin token. Skip destroying.
                """
                return false

            { AccessToken } = @models

            promisify (cb) =>
                AccessToken.destroyById tokenStr, cb

            .then =>
                delete @tokensById[tokenStr]


    ###*
    Find AccessToken model by tokenStr
    @private
    ###
    findById: (tokenStr) ->

        { AccessToken } = @models

        promisify (cb) =>
            AccessToken.findById tokenStr, cb



    ###*
    Create admin user, called once in 'init' function.
    @private
    ###
    createAdminUser: ->
        ____("creating admin user. id: #{ADMIN_USER.id}")
        { User } = @models

        promisify (cb) =>
            User.create ADMIN_USER, cb


    ###*
    Create admin role, called once in 'init' function.
    @private
    ###
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


    ###*
    Check the fetched results are valid
    @private
    ###
    validTokenStrs: (tokenStrs) ->

        Array.isArray(tokenStrs) and tokenStrs.length > 0 and tokenStrs.every (v) -> typeof v is 'string'



    ###*
    Create an error to indicate the tokenStrs are invalid
    @private
    ###
    invalidTokenError: (tokenStrs) ->

        new Error """
            AdminTokenManager could not fetch valid access tokens.
            Result: '#{tokenStrs}'
            Check if the valid function is passed to the 3rd arugment of run() method.

                var fn = function() {
                    return Promise.resolve(['token1', 'token2', 'token3'])
                };

                require('loopback-with-admin').run(models, config, { adminToken: {fetch: fn} })
        """



    ###*
    Create valid fetch function
    @private
    @static
    ###
    @createFetchFunction: (fetch) ->

        if not fetch?
            return => Promise.resolve([DEFAULT_TOKEN])

        if typeof fetch is 'string'
            return => Promise.resolve([fetch])

        if Array.isArray fetch
            return => Promise.resolve(fetch.slice())

        if typeof fetch isnt 'function'
            return => Promise.resolve([DEFAULT_TOKEN])

        # if typeof fetch is 'function'
        return =>
            Promise.resolve(fetch()).then (results) =>
                if typeof results is 'string'
                    return [results]

                if Array.isArray results
                    return results

                return [] # will throw error in init()


###*
Admin token

@class AdminToken
@private
###
class AdminToken

    constructor: (@id) ->
        @userId = ADMIN_USER.id
        @ttl = ONE_YEAR
        @isAdmin = true




module.exports = AdminTokenManager
