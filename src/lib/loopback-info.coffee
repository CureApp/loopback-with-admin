
###*
Loopback info

@class LoopbackInfo
###
class LoopbackInfo

    constructor: (server, generatedInMain = {}) ->
        if typeof server?.kill is 'function'
            @process = server
        else
            @lbServer = server

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
        if not @lbServer?
            throw new Error('Cannot get admin tokens when loopback is launched with {spawn: true} option.')

        @lbServer.app.lwaTokenManager.getCurrentTokens()



    ###*
    get environment

    @method getEnv
    @public
    @return {String} env
    ###
    getEnv: -> @buildInfo.env



    ###*
    kill loopback process

    @method kill
    @public
    ###
    kill: ->
        @process?.kill()


module.exports = LoopbackInfo
