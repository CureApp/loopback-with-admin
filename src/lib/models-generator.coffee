
{ normalize } = require 'path'

fs = require 'fs'

{ mkdirSyncRecursive, rmdirSyncRecursive }  = require 'wrench'

ModelSetting = require './model-setting'

class ModelsGenerator

    destinationDir : normalize "#{__dirname}/../../common/models"
    builtinDir     : normalize "#{__dirname}/../data/models"

    ###*
    @param {Facade} domain facade object in [base-domain](https://github.com/CureApp/base-domain)
    @param {Object} customModelsSetting model setting data, compatible with loopback's model-config.json and aclType
    ###
    constructor: (@domain, @customModelsSetting = {}) ->


    ###*
    generate JSON files with empty js files into common/models

    @method generate
    @public
    @return {Array} generatedModelNames
    ###
    generate: ->

        entityModels = @getEntityModelsFromDomain(domain)

        mkdirSyncRecursive @destinationDir

        modelNames = for EntityModel in entityModels

            modelSetting = @createModelSetting(EntityModel)
            modelName = modelSetting.getName()
            @generateJSONandJS(modelName, modelSetting.toStringifiedJSON())

        builtinModelNames = @generateBuiltinModels()

        return modelNames.concat builtinModelNames


    ###*
    reset

    @method reset
    @public
    @return
    ###
    reset: ->
        rmdirSyncRecursive @destinationDir


    ###*

    @method generateBuiltinModels
    @private
    ###
    generateBuiltinModels: ->

        for filename in fs.readdirSync @builtinDir

            [modelName, ext] = filename.split('.')
            setting = require @builtinDir + '/' + filename
            @generateJSONandJS(modelName, JSON.stringify(setting, null, 4))


    ###*
    generate JSON file and JS file of modelName

    @private
    @reurn {String} modelName
    ###
    generateJSONandJS: (modelName, jsonContent) ->

        jsonFilePath = normalize "#{@destinationDir}/#{modelName}.json"
        fs.writeFileSync(jsonFilePath, jsonContent)

        jsFilePath = normalize "#{@destinationDir}/#{modelName}.js"
        fs.writeFileSync(jsFilePath, @getEmptyJSContent())

        return modelName


    ###*
    get empty js content

    @private
    ###
    getEmptyJSContent: ->
        'module.exports = function(Model) {};'


    ###*
    get entity models from domain

    @private
    ###
    getEntityModelsFromDomain: (domain) ->
        # FIXME base-domain should implement their own 'getEntityModels()'

        domainFiles = fs.readdirSync domain.dirname
        entityModels = []

        for filename in domainFiles
            try
                klass = require normalize domain.dirname + '/' + filename
                continue if not klass.isEntity
                name = klass.getName()
                entityModels.push domain.getModel name
            catch e
                console.debug e
                console.debug e.stack

        return entityModels


    ###*
    create ModelSetting instance

    @private
    ###
    createModelSetting: (EntityModel) ->

        entityName = EntityModel.getName()
        customModelSetting = @customModelsSetting[entityName]

        return new ModelSetting(EntityModel, customModelSetting)


module.exports = ModelsGenerator
