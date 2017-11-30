
{ normalize } = require 'path'

fs = require 'fs-extra'

ModelDefinition = require './model-definition'
ModelConfigGenerator = require './model-config-generator'

class ModelsGenerator

    destinationDir : normalize "#{__dirname}/../../loopback/common/models"
    builtinDir     : normalize "#{__dirname}/../../default-values/models"

    ###*
    @param {Object} customModelDefinitions model definition data, compatible with loopback's model-config.json and aclType
    ###
    constructor: (customModelDefinitions) ->

        @definitions = @createModelDefinitions(customModelDefinitions)

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

        fs.mkdirsSync @destinationDir

        modelNames = for name, definition of @definitions
            @generateJSONandJS(name, definition)

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
            fs.removeSync @destinationDir

        @modelConfigGenerator.reset()


    ###*

    @method generateBuiltinModels
    @private
    ###
    generateBuiltinModels: ->

        for filename in fs.readdirSync @builtinDir
            [modelName, ext] = filename.split('.')
            definition = require @builtinDir + '/' + filename
            @generateJSONandJS(modelName, definition)


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
    generateJSONandJS: (modelName, modelDefinition) ->

        jsonFilePath = normalize "#{@destinationDir}/#{modelName}.json"
        jsFilePath = normalize "#{@destinationDir}/#{modelName}.js"

        if modelDefinition instanceof ModelDefinition
            jsonContent = modelDefinition.toStringifiedJSON()
        else
            jsonContent = JSON.stringify(modelDefinition, null, 2)
            fs.writeFileSync(jsonFilePath, jsonContent)
            fs.writeFileSync(jsFilePath, @getEmptyJSContent())
            return modelName

        fs.writeFileSync(jsonFilePath, jsonContent)
        fs.writeFileSync(jsFilePath, @getJSContent(modelDefinition.definition.validations))

        return modelName


    ###*
    get empty js content

    @private
    ###
    getEmptyJSContent: ->
        'module.exports = function(Model) {};'

    ###*
    get js content

    @private
    ###
    getJSContent: (validations) ->
        validateMethods = []
        for validation in validations
            for prop, rules of validation
                if rules.required
                    validateMethods.push("  Model.validatesPresenceOf('#{prop}');")
                if rules.pattern
                    validateMethods.push("  Model.validatesFormatOf('#{prop}', { with: /#{rules.pattern}/ });")
                if rules.min
                    validateMethods.push("  Model.validatesLengthOf('#{prop}', { min: #{rules.min} });")
                if rules.max
                    validateMethods.push("  Model.validatesLengthOf('#{prop}', { max: #{rules.max} });")

        head = 'module.exports = function(Model) {\n'
        foot = '\n};\n'
        head + validateMethods.join('\n') + foot

    ###*
    get RelationDefinition

    @private
    ###
    getRelationDefinitions: (customModelDefinition, customModelDefinitions) ->

        definitions = {}

        for relationName, relationDefinition of customModelDefinition.relations

            continue unless customModelDefinitions[relationName]

            switch relationDefinition.type
                when 'hasMany'
                    definitions[relationName] =
                        type: relationDefinition.type
                        aclType: customModelDefinitions[relationName].aclType

        return definitions

    ###*
    create ModelDefinition instances

    @private
    ###
    createModelDefinitions: (customModelDefinitions) ->

        definitions = {}

        for modelName, customModelDefinition of customModelDefinitions

            if customModelDefinition.relations?
                relationDefinitions = @getRelationDefinitions(customModelDefinition, customModelDefinitions)

            definitions[modelName] = new ModelDefinition(modelName, customModelDefinition, relationDefinitions)

        return definitions


module.exports = ModelsGenerator
