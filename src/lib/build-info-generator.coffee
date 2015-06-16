
{ normalize } = require 'path'

ConfigJSONGenerator = require './config-json-generator'

class BuildInfoGenerator extends ConfigJSONGenerator

    defaultConfigsPath: normalize "#{__dirname}/../../default-values"

    configNames: [ 'build-info' ]


    ###*
    @constructor
    ###
    constructor: (@domain, @customConfigs, @env) ->


    getMergedConfig: ->
        env           : @env
        customConfigs : @customConfigs
        domainType    : if @domain then @domain.constructor?.name ? 'object' else null
        domainDir     : @domain?.dirname
        buildAt       : new Date().toISOString()


    generate: ->
        generated = super()
        return generated['build-info']



module.exports = BuildInfoGenerator
