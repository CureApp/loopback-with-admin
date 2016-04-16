
###*
Loopback info

@class LoopbackInfo
###
class LoopbackInfo

    constructor: (@lbServer, generatedInMain = {}) ->

        { @config, @models, @buildInfo, @bootInfo } = generatedInMain


    ###*
    get hosting URL

    @method getURL
    @public
    @param {String} [hostName]
    @return {String} url
    ###
    getURL: (hostName) ->
        hostName ?= @config.server.host

        "#{hostName}:#{@config.server.port}#{@config.server.restApiRoot}"


    ###*
    get available admin access tokens

    @method getAdminTokens
    @public
    @return {Array(String)} tokens
    ###
    getAdminTokens: ->

        @lbServer.app.lwaTokenManager.getCurrentTokens()



    ###*
    get environment

    @method getEnv
    @public
    @return {String} env
    ###
    getEnv: -> @buildInfo.env



module.exports = LoopbackInfo
