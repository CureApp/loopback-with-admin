
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
    @param {Number} [options.intervalHours] Interval hours to fetch new admin token.
    ###
    launch: (adminTokenOptions = {}) -> new Promise (resolve, reject) =>

        @app = require(@entryPath)

        @app.lwaTokenManager = new AdminTokenManager(adminTokenOptions)

        return @app.start (err) =>

            console.log "err"
            console.log err

            return reject(err) if err

            @startRefreshingAdminTokens(intervalHours = Number(adminTokenOptions.intervalHours) || 12)

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
