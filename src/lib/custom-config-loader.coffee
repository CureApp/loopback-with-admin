

fs = require 'fs'

class CustomConfigLoader


    constructor: (@configPath, env) ->
        @env ?= env or process.env.NODE_ENV or 'development'


    ###*
    configを取得します. 特定のenvの設定があればそちらを優先
    config は JSON.parse / JSON.stringify されて元のファイルとの参照を失います

        dbConfig = new CustomConfigLoader(diranme, 'local').load('datasources')

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
    objectを複製

    @private
    ###
    clone: (obj) ->

        JSON.parse JSON.stringify obj


module.exports = CustomConfigLoader

