
{ normalize } = require 'path'

ConfigJSONGenerator = require './config-json-generator'

class ModelConfigGenerator extends ConfigJSONGenerator

    defaultConfigsPath: normalize "#{__dirname}/../../default-values"

    configNames: [ 'model-config' ]


    ###*
    @constructor
    ###
    constructor: (entityNames = []) ->

        @customConfigObj =
            'model-config': @getConfigByEntityNames(entityNames)


    generate: ->
        generated = super()
        return generated['model-config']


    ###*
    get config object by entity names
    @private
    @param {Array(String)} entityNames
    ###
    getConfigByEntityNames: (entityNames = []) ->

        config = {}
        for entityName in entityNames
            config[entityName] =
                dataSource: 'db'
                public: true

        return config

module.exports = ModelConfigGenerator
