
{ normalize } = require 'path'

ConfigJSONGenerator = require './config-json-generator'

class ModelConfigGenerator extends ConfigJSONGenerator

    defaultConfigsPath: normalize "#{__dirname}/../data"

    configNames: [ 'model-config' ]


    ###*
    @constructor
    ###
    constructor: (@entityNames) ->

    ###*
    returns custom model-config calculated by domain

    @method loadCustomConfig
    @return {Object} customModelConfig
    ###
    loadCustomConfig: ->

        config = {}
        for entityName in @entityNames
            config[entityName] =
                dataSource: 'db'
                public: true

        return config


    reset: ->
        # WIP

module.exports = ModelConfigGenerator
