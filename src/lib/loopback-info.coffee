
###*
Loopback info

@class LoopbackInfo
###
class LoopbackInfo

    constructor: (server = {}, generatedInMain = {}) ->
        if typeof server.kill is 'function'
            @process = server
        else
            @app = server

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
