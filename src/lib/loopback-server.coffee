
{ normalize } = require 'path'

AdminTokenManager = require '../server/admin-token-manager'

###*
launches loopback server

@class LoopbackServer
###
class LoopbackServer

    entryPath: normalize __dirname + '/../../loopback/server/server.js'

    launch: -> new Promise (resolve) =>

        @app = require(@entryPath)

        @app.lwaTokenManager = new AdminTokenManager(@app)

        return @app.start(resolve)


module.exports = LoopbackServer
