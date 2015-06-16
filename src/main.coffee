
{ normalize } = require 'path'

LoopbackProcessLauncher = require './lib/loopback-process-launcher'
LoopbackInfo   = require './lib/loopback-info'
LoopbackServer = require './lib/loopback-server'

ConfigJSONGenerator  = require './lib/config-json-generator'
ModelsGenerator      = require './lib/models-generator'
BuildInfoGenerator   = require './lib/build-info-generator'
CustomConfigs        = require './lib/custom-configs'

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
    @param {Object|String} [config] config object or config directory containing config info
    @param {Boolean} [options.reset] reset previously-generated settings before generation
    @param {String} [options.env] set environment (production|development|...)
    @param {Boolean} [options.spawn] if true, spawns child process of loopback
    return {Promise(LoopbackInfo)}
    ###
    @runWithDomain: (domain, config, options = {}) ->

        main = new @(domain, config, options.env)

        main.reset() unless options.reset is false

        generated = main.generate()

        @launchLoopback(options.spawn).then (server) =>
            return new LoopbackInfo(server, generated)


    ###*
    entry point.
    run loopback without domain

    @method runWithoutDomain
    @public
    @static
    @param {Object|String} [config] config object or config directory containing config info
    @param {Boolean} [options.reset] reset previously-generated settings before generation
    @param {String} [options.env] set environment (production|development|...)
    @param {Boolean} [options.spawn] if true, spawns child process of loopback
    return {Promise(LoopbackInfo)}
    ###
    @runWithoutDomain: (config, options) ->
        emptyDir = normalize __dirname + '/../default-values/empty-domain-dir'
        domain = require('base-domain').createInstance(dirname: emptyDir)
        @runWithDomain(domain, config, options)



    ###*
    @constructor
    @private
    ###
    constructor: (@domain, configs, @env) ->

        customConfigs = new CustomConfigs(configs)

        @env ?= process.env.NODE_ENV or 'development'

        modelDefinitions = customConfigs.loadModelDefinitions()
        configObj        = customConfigs.toObject()

        @configJSONGenerator = new ConfigJSONGenerator(configObj, @env)
        @modelsGenerator     = new ModelsGenerator(modelDefinitions, @domain)
        @buildInfoGenerator  = new BuildInfoGenerator(@domain, configObj, @env)


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
