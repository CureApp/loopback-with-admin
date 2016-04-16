
{ normalize } = require 'path'

fs = require 'fs'

class ConfigJSONGenerator

    defaultConfigsPath: normalize "#{__dirname}/../../default-values/non-model-configs"
    destinationPath   : normalize "#{__dirname}/../../loopback/server"

    configNames: [
        'datasources'
        'middleware'
        'server'
        'push-credentials'
    ]

    ###*
    default-configs/server.json will be server/config.json

    @property destinationNamePairs
    @private
    ###
    destinationNamePairs:
        server: 'config'


    ###*

    @constructor
    @param {Object} customConfigObj
    @param {String} env
    ###
    constructor: (@customConfigObj = {}, env) ->


    ###*
    generate JSON files into server dir

    @method generate
    @public
    @return {Object} generatedContents
    ###
    generate: ->

        generatedContents = {}

        for configName in @configNames

            config = @getMergedConfig(configName)

            path = @getDestinationPathByName(configName)

            fs.writeFileSync(path, JSON.stringify config, null, 2)

            generatedContents[configName] = config

        return generatedContents

    ###*
    remove previously-generated JSON files

    @method reset
    @public
    ###
    reset: ->
        for configName in @configNames
            path = @getDestinationPathByName(configName)
            if fs.existsSync path
                fs.unlinkSync(path)



    ###*
    new config path
    ###
    getDestinationPathByName: (configName) ->

        filename = @destinationNamePairs[configName] ? configName

        return normalize @destinationPath + '/' + filename + '.json'


    ###*
    merge custom and default for each config names

    @private
    ###
    getMergedConfig: (configName) ->

        defaultConfig = @loadDefaultConfig(configName)
        customConfig  = @customConfigObj[configName]

        return @merge customConfig, defaultConfig



    ###*
    merge two objects into one new object
    object at 1st argument overrides that at 2nd

    @param {Object} dominant
    @param {Object} base
    @return {Object} merged
    @private
    ###
    merge: (dominant = {}, base = {}) ->

        merged = {}
        merged[k] = v for own k,v of base

        for own k, sub of dominant
            if merged[k]? and typeof merged[k] is 'object' and v?
                # merges subobject
                merged[k] = @merge sub, merged[k]
            else
                merged[k] = sub

        return merged


    ###*
    load default config JSON files

    @private
    ###
    loadDefaultConfig: (configName) ->

        try
            require "#{@defaultConfigsPath}/#{configName}.json"
        catch e
            return null


module.exports = ConfigJSONGenerator
