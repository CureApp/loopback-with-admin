
LoopbackProcessLauncher = require './lib/loopback-process-launcher'
LoopbackInfo   = require './lib/loopback-info'
LoopbackServer = require './lib/loopback-server'

ConfigJSONGenerator   = require './lib/config-json-generator'
ModelsGenerator       = require './lib/models-generator'
BuildInfoGenerator    = require './lib/build-info-generator'
CustomConfigs         = require './lib/custom-configs'
LoopbackBootGenerator = require './lib/loopback-boot-generator'

###*
entry point

@class Main
###
class Main

    ###*
    entry point.
    run loopback with model definitions, config

    @method run
    @public
    @static
    @param {Object} loopbackDefinitions
    @param {Object|String} [config] config object or config directory containing config info
    @param {Boolean} [options.reset] reset previously-generated settings before generation
    @param {String} [options.env] set environment (production|development|...)
    @param {Object} [options.adminToken] options for admin token manager
    @param {Function|Array(String)} [options.fetch] function to return admin tokens (or promise of it). When string[] is given, these value are used for the admin access token.
    @param {Number} [options.adminToken.intervalHours] IntervalHours to fetch new admin token.
    return {Promise(LoopbackInfo)}
    ###
    @run: (loopbackDefinitions, config, options = {}) ->

        main = new @(loopbackDefinitions, config, options.env)

        main.reset() unless options.reset is false

        generated = main.generate()

        @launchLoopback(options.adminToken, options.spawn).then (server) =>
            return new LoopbackInfo(server, generated)


    ###*
    @constructor
    @private
    ###
    constructor: (loopbackDefinitions, configs, @env) ->

        if loopbackDefinitions.models?
            modelDefinitions = loopbackDefinitions.models
            { customRoles } = loopbackDefinitions
        else
            modelDefinitions = loopbackDefinitions
            customRoles = null

        @env ?= process.env.NODE_ENV or 'development'

        customConfigs = new CustomConfigs(configs, @env)
        configObj = customConfigs.toObject()

        @configJSONGenerator = new ConfigJSONGenerator(configObj, @env)
        @modelsGenerator     = new ModelsGenerator(modelDefinitions)
        @bootGenerator       = new LoopbackBootGenerator(customRoles: customRoles)
        @buildInfoGenerator  = new BuildInfoGenerator(modelDefinitions, configObj, @env)


    ###*
    @private
    ###
    generate: ->
        config    : @configJSONGenerator.generate()
        models    : @modelsGenerator.generate()
        buildInfo : @buildInfoGenerator.generate()
        bootInfo  : @bootGenerator.generate()

    ###*
    @private
    ###
    reset: ->
        @configJSONGenerator.reset()
        @modelsGenerator.reset()
        @buildInfoGenerator.reset()
        @bootGenerator.reset()



    ###*
    run loopback

    @private
    ###
    @launchLoopback: (adminTokenOptions, spawnChildProcess) ->

        if spawnChildProcess
            console.error('`options.spawn` is deprecated. It cannot set admin access token.')
            new LoopbackProcessLauncher().launch()
        else
            new LoopbackServer().launch(adminTokenOptions)

module.exports = Main
