
{ normalize } = require 'path'

fs = require 'fs'

{ mkdirSyncRecursive, rmdirSyncRecursive }  = require 'wrench'

ModelDefinition = require './model-definition'
EmptyModelDefinition = require './empty-model-definition'
ModelConfigGenerator = require './model-config-generator'

class ModelsGenerator

    destinationDir : normalize "#{__dirname}/../../loopback/common/models"
    builtinDir     : normalize "#{__dirname}/../../default-values/models"

    ###*
    @param {Object} customModelDefinitions model definition data, compatible with loopback's model-config.json and aclType
    @param {Facade} domain facade object in [base-domain](https://github.com/CureApp/base-domain)
    ###
    constructor: (customModelDefinitions, domain) ->

        @definitions = @createModelDefinitions(customModelDefinitions, domain)

        entityNames = Object.keys @definitions
        @modelConfigGenerator = new ModelConfigGenerator(entityNames)


    ###*
    generate model-config.json and model definition files

    @method generate
    @public
    @return {Object} generatedInfo
    ###
    generate: ->

        modelConfig = @generateModelConfig()
        modelNames  = @generateDefinitionFiles()

        config: modelConfig
        names : modelNames


    ###*
    generate JSON files with empty js files into common/models

    @method generateDefinitionFiles
    @return {Array} generatedModelNames
    ###
    generateDefinitionFiles: ->

        mkdirSyncRecursive @destinationDir

        modelNames = for name, definition of @definitions

            @generateJSONandJS(name, definition.toStringifiedJSON())

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

        @modelConfigGenerator.reset()


    ###*

    @method generateBuiltinModels
    @private
    ###
    generateBuiltinModels: ->

        for filename in fs.readdirSync @builtinDir

            [modelName, ext] = filename.split('.')
            definition = require @builtinDir + '/' + filename
            @generateJSONandJS(modelName, JSON.stringify(definition, null, 2))


    ###*
    @method generateModelConfig
    @private
    ###
    generateModelConfig: ->

        @modelConfigGenerator.generate()



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
    create ModelDefinition instances

    @private
    ###
    createModelDefinitions: (customModelDefinitions, domain) ->

        definitions = {}

        for modelName, customModelDefinition of customModelDefinitions

            definitions[modelName] = @createDefinition(customModelDefinition, modelName, domain)

        @setHasManyRelations(definitions)

        return definitions


    ###*
    @method createDefinition
    @private
    @return {ModelDefinition}
    ###
    createDefinition: (customModelDefinition, modelName, domain) ->

        if domain?.hasClass(modelName) and domain.getModel(modelName).isEntity

            Entity = domain.getModel modelName
            return new ModelDefinition(Entity, customModelDefinition)

        else
            return new EmptyModelDefinition(modelName, customModelDefinition)


    ###*
    set "hasMany" relations

    @private
    ###
    setHasManyRelations: (definitions) ->

        for modelName, definition of definitions
            for prop, typeInfo of definition.getEntityPropInfo()
                relModelName = typeInfo.model
                relModelDefinition = definitions[relModelName]
                relModelDefinition?.setHasManyRelation(modelName)


module.exports = ModelsGenerator
