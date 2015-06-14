
Promise = require('es6-promise').Promise

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

    @param {Facade} domain  (the same interface as base-domain)
    @param {String} configDir directory containing config info
    @param {Object} [options.reset] reset previously-generated settings before generation
    @param {Object} [options.env] set environment (production|development|...)
    return {Promise}
    ###
    @runWithDomain: (@domain, @configDir, options = {}) ->

        { @env, reset } = options

        modelDefinitions = @loadModelDefinitions()

        @configJSONGenerator  = new ConfigJSONGenerator(@configDir, @env)
        @modelsGenerator      = new ModelsGenerator(@domain, modelDefinitions)
        @buildInfoGenerator   = new BuildInfoGenerator(@domain, @configDir, @env, reset)

        @reset() if reset
        @generate()
        @startLoopback()



    ###*
    @private
    ###
    @loadModelDefinitions: -> require(@configDir + '/models')


    ###*
    @private
    ###
    @generate: ->
        @configJSONGenerator.generate()
        @modelsGenerator.generate()
        @buildInfoGenerator.generate()


    ###*
    @private
    ###
    @reset: ->
        @configJSONGenerator.reset()
        @modelsGenerator.reset()
        @buildInfoGenerator.reset()



    ###*
    run loopback (in child process)

    @private
    ###
    @startLoopback: -> new Promise (resolve, reject) ->

        timer = setTimeout ->
            reject new Error('timeout after 30sec')
        , 30 * 1000

        lbProcess = require('child_process').spawn ['node', __dirname + '/../server/server.js']
        lbProcess.stdout.setEncoding 'utf8'

        prevChunk = ''

        lbProcess.stdout.on 'data', (chunk) ->
            data = prevChunk + chunk

            if data.match('LOOPBACK_WITH_DOMAIN_STARTED')
                clearTimeout timer
                resolve()

            prevChunk = chunk



module.exports = Main
