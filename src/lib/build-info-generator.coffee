
{ normalize } = require 'path'

ConfigJSONGenerator = require './config-json-generator'

class BuildInfoGenerator extends ConfigJSONGenerator

    defaultConfigsPath: normalize "#{__dirname}/../data"

    configNames: [ 'build-info' ]


    ###*
    @constructor
    ###
    constructor: (@domain, @configDir, @env, @reset) ->


    ###*
    returns custom config

    @method loadCustomConfig
    @return {Object} customConfig
    ###
    loadCustomConfig: ->
        env        : @env
        reset      : @reset
        configDir  : @configDir
        domainType : @domain.constructor?.name ? 'object'
        domainDir  : @domain.dirname
        buildAt    : new Date().toISOString()


module.exports = BuildInfoGenerator
