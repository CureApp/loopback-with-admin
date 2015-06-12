
{ normalize } = require 'path'

fs = require 'fs'

class ConfigJSONGenerator

    defaultConfigsPath: normalize "#{__dirname}/../default-configs"
    destinationPath   : normalize "#{__dirname}/../server"

    configNames: [
        'admin'
        'datasources'
        'middleware'
        'model-config'
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
    @param {Object} customConfigs

        admin:
            accessToken: 'xxx'
        'push-credentials':
            gcmServerApiKey: 'yyy'

    @param {Object} strategies merging strategies, currently unused.
    ###
    constructor: (@customConfigs = {}, @strategies = {}) ->


    ###*
    generate JSON files into server dir

    @method generate
    @public
    @return {Array} generatedFileNames
    ###
    generate: ->

        configs = @getMergedConfigs()

        for configName, config of configs
            path = @getDestinationPathByName(configName)

            fs.writeFileSync(path, JSON.stringify config)

            normalize path # for returning value

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
    getMergedConfigs: ->

        mergedConfigs = {}

        for configName, defaultConfig of @loadDefaultConfigs()

            customConfig = @customConfigs[configName]

            if customConfig?
                mergedConfigs[configName] = @merge(customConfig, defaultConfig)
            else
                mergedConfigs[configName] = defaultConfig

        return mergedConfigs


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
    loadDefaultConfigs: ->

        configs = {}

        for name in @configNames
            configs[name] = require @defaultConfigsPath + '/' + name + '.json'

        return configs


module.exports = ConfigJSONGenerator
