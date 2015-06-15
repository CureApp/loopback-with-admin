
LoopbackProcessLauncher = require './lib/loopback-process-launcher'
LoopbackInfo   = require './lib/loopback-info'
LoopbackServer = require './lib/loopback-server'

ConfigJSONGenerator  = require './lib/config-json-generator'
ModelsGenerator      = require './lib/models-generator'
BuildInfoGenerator   = require './lib/build-info-generator'

###*
entry point

@class Main
###
class Main

    ###*
    entry point.
    run loopback with domain, config

    @method runWithDomain
    @public
    @static
    @param {Facade} domain  (the same interface as base-domain)
    @param {String} configDir directory containing config info
    @param {Boolean} [options.reset] reset previously-generated settings before generation
    @param {String} [options.env] set environment (production|development|...)
    @param {Boolean} [options.spawn] if true, spawns child process of loopback
    return {Promise(LoopbackInfo)}
    ###
    @runWithDomain: (domain, configDir, options = {}) ->

        main = new @(domain, configDir, options.env)

        main.reset() unless options.reset is false

        generated = main.generate()

        @launchLoopback(options.spawn).then (server) =>
            return new LoopbackInfo(server, generated)


    ###*
    @constructor
    @private
    ###
    constructor: (@domain, @configDir, @env) ->

        @env ?= process.env.NODE_ENV ? 'development'

        modelDefinitions = @loadModelDefinitions()

        @configJSONGenerator = new ConfigJSONGenerator(@configDir, @env)
        @modelsGenerator     = new ModelsGenerator(@domain, modelDefinitions)
        @buildInfoGenerator  = new BuildInfoGenerator(@domain, @configDir, @env)


    ###*
    @private
    ###
    loadModelDefinitions: ->

        return {} if not @configDir

        try
            require(@configDir + '/model-definitions')
        catch e
            console.log e
            return {}


    ###*
    @private
    ###
    generate: ->
        config    : @configJSONGenerator.generate()
        models    : @modelsGenerator.generate()
        buildInfo : @buildInfoGenerator.generate()

    ###*
    @private
    ###
    reset: ->
        @configJSONGenerator.reset()
        @modelsGenerator.reset()
        @buildInfoGenerator.reset()



    ###*
    run loopback

    @private
    ###
    @launchLoopback: (spawnChildProcess) ->

        if spawnChildProcess
            new LoopbackProcessLauncher().launch()
        else
            new LoopbackServer().launch()

module.exports = Main
