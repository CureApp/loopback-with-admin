
{ normalize } = require 'path'

fs = require 'fs'

CustomConfigLoader = require './custom-config-loader'

class ConfigJSONGenerator

    defaultConfigsPath: normalize "#{__dirname}/../../default-configs"
    destinationPath   : normalize "#{__dirname}/../../loopback/server"

    configNames: [
        'admin'
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
    @param {String} customConfigsPath
    @param {String} env
    ###
    constructor: (customConfigsPath, env) ->

        @customConfigLoader = new CustomConfigLoader customConfigsPath, env


    ###*
    generate JSON files into server dir

    @method generate
    @public
    @return {Array} generatedFileNames
    ###
    generate: ->

        for configName in @configNames

            config = @getMergedConfig(configName)

            path = @getDestinationPathByName(configName)

            fs.writeFileSync(path, JSON.stringify config, null, 2)

            normalize path # for returning value

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
        customConfig  = @loadCustomConfig(configName)

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
    load custom config

    @method loadCustomConfig
    @param {String} configName
    @protected
    ###
    loadCustomConfig: (configName) ->

        @customConfigLoader.load(configName)


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
