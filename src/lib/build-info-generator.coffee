
{ normalize } = require 'path'

ConfigJSONGenerator = require './config-json-generator'

class BuildInfoGenerator extends ConfigJSONGenerator

    defaultConfigsPath: normalize "#{__dirname}/../../default-values"

    configNames: [ 'build-info' ]


    ###*
    @constructor
    ###
    constructor: (@domain, @configDir, @env) ->


    ###*
    returns custom config

    @method loadCustomConfig
    @return {Object} customConfig
    ###
    loadCustomConfig: ->
        env        : @env
        configDir  : @configDir
        domainType : @domain.constructor?.name ? 'object'
        domainDir  : @domain.dirname
        buildAt    : new Date().toISOString()


module.exports = BuildInfoGenerator
