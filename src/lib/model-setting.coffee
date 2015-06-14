

AclGenerator = require './acl-generator'

class ModelSetting

    constructor: (@Entity, @customSetting = {}) ->

        @aclType = @customSetting.aclType ? 'admin'

        @setting =
            name        : @getName()
            plural      : @getName()
            base        : "PersistedModel"
            idInjection : true
            properties  : {}
            validations : []

        @setting[k] = @customSetting[k] for k, v of @customSetting
        delete @setting.aclType


    ###*
    get model name

    @method getName
    @public
    @return {String} modelName
    ###
    getName: ->
        @Entity.getName()


    ###*
    get stringified JSON contents about the model

    @method toStringifiedJSON
    @public
    @return {String} stringifiedJSON
    ###
    toStringifiedJSON: ->
        JSON.stringify @toJSON()


    ###*
    get setting of the model

    @method toJSON
    @private
    @return {Object} setting
    ###
    toJSON: ->
        @setting.acls      = @getACL()
        @setting.relations = @getRelations()

        return @setting


    ###*
    is model extend User?

    @private
    @return {Boolean}
    ###
    isUser: ->
        @setting.base is 'User'


    ###*
    get ACL by aclType

    @private
    ###
    getACL: ->
        new AclGenerator(@aclType, @isUser()).generate()


    ###*
    get relations by models

    @private
    ###
    getRelations: ->
        return {} # WIP



module.exports = ModelSetting
