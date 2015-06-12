

{ normalize } = require 'path'

fs = require 'fs'
mkdirp = require 'mkdirp'

class ModelsGenerator

    modelsDir: normalize "#{__dirname}/../../common/models"

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
        acl = @acls[entityName]
        modelConfig = @modelConfigs[entityName]

        return new ModelSetting(EntityModel, acl, modelConfig)

module.exports = ModelsGenerator
