
{ normalize } = require 'path'

AdminTokenManager = require '../server/admin-token-manager'

###*
launches loopback server

@class LoopbackServer
###
class LoopbackServer

    entryPath: normalize __dirname + '/../../loopback/server/server.js'

    ###*
    @param {Function|Array(String)} [options.fetch] function to return admin tokens (or promise of it). When string[] is given, these value are used for the admin access token.
    @param {String} [options.email=loopback-with-admin@example.com] email address for admin user
    @param {String} [options.id=loopback-with-admin-user-id] id of admin user
    @param {String} [options.password=admin-user-password] password of admin user
    @param {Number} [options.intervalHours] Interval hours to fetch new admin token.
    ###
    launch: (options = {}) -> new Promise (resolve, reject) =>

        @app = require(@entryPath)

        @app.lwaTokenManager = new AdminTokenManager(options)

        return @app.start (err) =>

            return reject(err) if err

            @startRefreshingAdminTokens(intervalHours = Number(options.intervalHours) || 12)

            resolve()


    ###*
    Start refreshing admin access tokens

    @public
    @method startRefreshingAdminTokens
    @param {Number} [intervalHours=12]
    ###
    startRefreshingAdminTokens: (intervalHours = 12) ->

        console.log "Admin token will be refreshed every #{intervalHours} hours."

        clearInterval(@timer) if @timer?

        @timer = setInterval =>

            @app.lwaTokenManager.refreshTokens()

        , intervalHours * 3600 * 1000



    ###*
    Check if the regular timer refreshing admin access tokens is set

    @public
    @method isRefreshingAdminTokens
    @return {Boolean}
    ###
    isRefreshingAdminTokens: -> @timer?


    ###*
    Stop refreshing admin access tokens

    @public
    @method stopRefreshingAdminTokens
    ###
    stopRefreshingAdminTokens: ->

        console.log "Admin token will no more be refreshed."
        clearInterval @timer if @timer?



module.exports = LoopbackServer
