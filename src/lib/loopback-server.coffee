
{ normalize } = require 'path'

AdminTokenManager = require '../server/admin-token-manager'

###*
launches loopback server

@class LoopbackServer
###
class LoopbackServer

    entryPath: normalize __dirname + '/../../loopback/server/server.js'

    ###*
    @param {Function|String} [options.fetchNew] function to return new admin token (or promise of it). When string is given, the value is used for the admin access token. Default value is 'loopback-with-admin-access-token'
    @param {Function|Array(String)} [options.fetchAll] function to return initial admin tokens (or promise of it). When string[] is given, these value are used for the admin access token.
    @param {Number} [options.intervalHours] Interval hours to fetch new admin token.
    @param {Number} [options.maxTokens] The limit of the number of admin access tokens. Default is the length of the result of fetchAll()
    ###
    launch: (adminTokenOptions) -> new Promise (resolve) =>

        @app = require(@entryPath)

        @app.lwaTokenManager = new AdminTokenManager(adminTokenOptions)

        return @app.start(resolve)


module.exports = LoopbackServer
