

fs = require 'fs'

class CustomConfigLoader


    constructor: (@configPath, env) ->
        @env ?= env or process.env.NODE_ENV or 'development'


    ###*
    load config by name. environment-specific config priors when exists.

        dbConfig = new CustomConfigLoader(diranme, 'development').load('datasources')

    @method load
    @public
    ###
    load: (configName) ->

        envFilePath = "#{@configPath}/#{@env}/#{configName}.coffee"

        if fs.existsSync envFilePath
            return @clone require envFilePath

        commonFilePath = "#{@configPath}/common/#{configName}.coffee"

        if fs.existsSync commonFilePath
            return @clone require commonFilePath

        # console.log """config: #{configName} is not found in #{@configPath} (env = #{@env})"""

        return {}

    ###*
    clone object

    @private
    ###
    clone: (obj) ->

        JSON.parse JSON.stringify obj


module.exports = CustomConfigLoader

