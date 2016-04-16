
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
    launch: (adminTokenOptions) -> new Promise (resolve) =>

        @app = require(@entryPath)

        @app.lwaTokenManager = new AdminTokenManager(adminTokenOptions)

        return @app.start(resolve)


module.exports = LoopbackServer
