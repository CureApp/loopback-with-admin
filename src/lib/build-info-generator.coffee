
{ normalize } = require 'path'

ConfigJSONGenerator = require './config-json-generator'

class BuildInfoGenerator extends ConfigJSONGenerator

    defaultConfigsPath: normalize "#{__dirname}/../../default-values"

    configNames: [ 'build-info' ]


    ###*
    @constructor
    ###
    constructor: (@modelDefinitions, @customConfigs, @env) ->


    getMergedConfig: ->
        env              : @env
        customConfigs    : @customConfigs
        modelDefinitions : @modelDefinitions
        buildAt          : new Date().toISOString()


    generate: ->
        generated = super()
        return generated['build-info']



module.exports = BuildInfoGenerator
