
{ normalize } = require 'path'

fs = require 'fs'

{ mkdirSyncRecursive, rmdirSyncRecursive }  = require 'wrench'

ModelDefinition = require './model-definition'

class ModelsGenerator

    destinationDir : normalize "#{__dirname}/../../common/models"
    builtinDir     : normalize "#{__dirname}/../data/models"

    ###*
    @param {Facade} domain facade object in [base-domain](https://github.com/CureApp/base-domain)
    @param {Object} customModelDefinitions model definition data, compatible with loopback's model-config.json and aclType
    ###
    constructor: (@domain, @customModelDefinitions = {}) ->


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

            modelDefinition = @createModelDefinition(EntityModel)
            modelName = modelDefinition.getName()
            @generateJSONandJS(modelName, modelDefinition.toStringifiedJSON())

        builtinModelNames = @generateBuiltinModels()

        return modelNames.concat builtinModelNames


    ###*
    reset

    @method reset
    @public
    @return
    ###
    reset: ->
        if fs.existsSync @destinationDir
            rmdirSyncRecursive @destinationDir


    ###*

    @method generateBuiltinModels
    @private
    ###
    generateBuiltinModels: ->

        for filename in fs.readdirSync @builtinDir

            [modelName, ext] = filename.split('.')
            definition = require @builtinDir + '/' + filename
            @generateJSONandJS(modelName, JSON.stringify(definition, null, 4))


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
                console.log e
                console.log e.stack

        return entityModels


    ###*
    create ModelDefinition instance

    @private
    ###
    createModelDefinition: (EntityModel) ->

        entityName = EntityModel.getName()
        customModelDefinition = @customModelDefinitions[entityName]

        return new ModelDefinition(EntityModel, customModelDefinition)


module.exports = ModelsGenerator
