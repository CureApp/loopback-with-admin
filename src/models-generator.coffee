

{ normalize } = require 'path'

fs = require 'fs'
mkdirp = require 'mkdirp'

class ModelsGenerator

    modelsDir: normalize "#{__dirname}/../common/models"

    ###*
    @param {Facade} domain facade object in [base-domain](https://github.com/CureApp/base-domain)
    @param {Object} acls ACL setting. key: modelName, value: ACL type (one of 'owner', 'admin', 'public-read')
    @param {Object} modelConfigs model config data, compatible with loopback's model-config.json
    ###
    constructor: (@domain, @acls = {}, @modelConfigs = {}) ->


    ###*
    generate JSON files with empty js files into common/models

    @method generate
    @public
    @return {Array} generatedFileNames
    ###
    generate: ->

        entityModels = @getEntityModelsFromDomain(domain)

        for EntityModel in entityModels
            modelSetting = @createModelSetting(EntityModel, @acls[entityName])

            jsonFilePath = @getDestinationPath(modelSetting.getName(), 'json')
            fs.writeFileSync(jsonFilePath, modelSetting.toStringifiedJSON())

            jsFilePath = @getDestinationPath(modelSetting.getName(), 'js')
            fs.writeFileSync(jsonFilePath, @getEmptyJSContent())


    ###*
    get path to save model file

    @private
    ###
    getDestinationPath: (modelName, extName) ->
        return normalize "#{@modelsDir}/#{modelName}.#{extName}"


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
        domainFiles = fs.readdirSync domain.dirname
        filename in domainFiles


    ###*
    create ModelSetting instance

    @private
    ###
    createModelSetting: (EntityModel) ->

        entityName = EntityModel.getName()
        acl = @acls[entityName]
        modelConfig = @modelConfigs[entityName]

        return new ModelSetting(EntityModel, acl, modelConfig)

module.exports = ModelsGenerator
