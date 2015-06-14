
{ normalize } = require 'path'

ConfigJSONGenerator = require './config-json-generator'

class ModelConfigGenerator extends ConfigJSONGenerator

    defaultConfigsPath: normalize "#{__dirname}/../data"

    configNames: [ 'model-config' ]


    ###*
    @constructor
    ###
    constructor: (@domain) ->


    ###*
    returns custom model-config calculated by domain

    @method loadCustomConfig
    @return {Object} customModelConfig
    ###
    loadCustomConfig: ->

        return {}


module.exports = ModelConfigGenerator
