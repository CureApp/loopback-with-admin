
fs = require 'fs'

class CustomConfigs

    constructor: (configs = {}, env) ->
        if typeof configs is 'string' # parse is as a configDir
            configDir = configs
            @configs = @loadDir(configDir, env)
        else
            @configs = @clone configs
            delete @configs.models


    toObject: ->
        return @clone @configs


    loadDir: (configDir, env) ->

        configs = {}

        if env
            envDir = "#{configDir}/#{env}"
            for configFile in fs.readdirSync(envDir)
                [configName, ext] = configFile.split('.')
                configs[configName] = require(envDir + '/' + configFile) if ext in ['coffee', 'js', 'json']

        commonDir = "#{configDir}/common"
        if fs.existsSync commonDir
            for configFile in fs.readdirSync(commonDir)
                [configName, ext] = configFile.split('.')
                configs[configName] ?= require(commonDir + '/' + configFile) if ext in ['coffee', 'js', 'json']

        return configs


    clone: (obj) ->
        for k, v of obj
            if v? and typeof v is 'object'
                obj[k] = @clone(v)
            else
                obj[k] = v

        return obj


module.exports = CustomConfigs
