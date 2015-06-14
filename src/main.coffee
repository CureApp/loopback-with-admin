
Promise = require('es6-promise').Promise

ConfigJSONGenerator  = require './lib/config-json-generator'
ModelConfigGenerator = require './lib/model-config-generator'
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

        configJSONGenerator  = new ConfigJSONGenerator(@configDir, @env)
        modelConfigGenerator = new ModelConfigGenerator(@domain)
        modelsGenerator      = new ModelsGenerator(@domain)
        buildInfoGenerator   = new BuildInfoGenerator(@domain, @configDir, @env, reset)

        if reset
            configJSONGenerator.reset()
            modelConfigGenerator.reset()
            modelsGenerator.reset()
            buildInfoGenerator.reset()

        configJSONGenerator.generate()
        modelsGenerator.generate()
        modelConfigGenerator.generate()
        buildInfoGenerator.generate()

        return @startLoopback()


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
