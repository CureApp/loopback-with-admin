
Promise = require('es6-promise').Promise

ConfigJSONGenerator  = require './lib/config-json-generator'
ModelConfigGenerator = require './lib/model-config-generator'
ModelsGenerator      = require './lib/models-generator'

###*
entry point

@class Main
###
class Main

    ###*
    entry point.
    run loopback with domain, config

    @param {Facade} domain  (the same interface as base-domain)
    @param {String} configDir directory containing config info
    @param {Object} [options.reset] reset previously-generated settings before generation
    @param {Object} [options.env] set environment (production|development|...)
    return {Promise}
    ###
    @runWithDomain: (@domain, @configDir, options = {}) ->

        { @env, reset } = options

        configJSONGenerator  = new ConfigJSONGenerator(@configDir, @env)
        modelConfigGenerator = new ModelConfigGenerator(@domain)
        modelsGenerator      = new ModelsGenerator(@domain)

        if reset
            configJSONGenerator.reset()
            modelConfigGenerator.reset()
            modelsGenerator.reset()


        configJSONGenerator.generate()
        modelsGenerator.generate()
        modelConfigGenerator.generate()


        return @startLoopback()


    ###*
    run loopback

    @private
    ###
    @startLoopback: ->

        app = require('../server/server')

        return new Promise (resolve) ->
            app.start resolve


module.exports = Main
