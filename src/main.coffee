
LoopbackLauncher = require './lib/loopback-launcher'

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
    @param {Object} [options.reset] reset previously-generated settings before generation
    @param {Object} [options.env] set environment (production|development|...)
    return {Promise}
    ###
    @runWithDomain: (domain, configDir, options = {}) ->

        main = new @(domain, configDir, options.env)

        main.reset() unless options.reset is false
        main.generate()

        @startLoopback()


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
        try
            require(@configDir + '/model-definitions')
        catch e
            console.log e
            return {}


    ###*
    @private
    ###
    generate: ->
        @configJSONGenerator.generate()
        @modelsGenerator.generate()
        @buildInfoGenerator.generate()


    ###*
    @private
    ###
    reset: ->
        @configJSONGenerator.reset()
        @modelsGenerator.reset()
        @buildInfoGenerator.reset()



    ###*
    run loopback (in child process)

    @private
    ###
    @startLoopback: ->
        new LoopbackLauncher().launch()

module.exports = Main
