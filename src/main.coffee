
{ normalize } = require 'path'
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
    @startLoopback: -> new Promise (resolve, reject) ->

        entryPath = normalize __dirname + '/../server/server.js'

        lbProcess = require('child_process').spawn 'node', [entryPath]
        lbProcess.stdout.setEncoding 'utf8'

        lbProcess.on 'exit', (code) -> reject new Error "process exit with error code #{code}"
        lbProcess.on 'error', (e) ->
            lbProcess.kill()
            reject new Error e

        prevChunk = ''

        timer = setTimeout ->
            lbProcess.kill()
            reject new Error('timeout after 30sec')
        , 30 * 1000

        lbProcess.stdout.on 'data', (chunk) ->
            data = prevChunk + chunk

            if data.match('LOOPBACK_WITH_DOMAIN_STARTED')
                clearTimeout timer
                lbProcess.removeAllListeners()
                lbProcess.stdout.removeAllListeners()

                resolve(lbProcess)

            prevChunk = chunk


module.exports = Main
