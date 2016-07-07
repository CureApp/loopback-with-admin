

AclGenerator = require './acl-generator'

###*
@class ModelDefinition
###
class ModelDefinition

    constructor: (@modelName, @customDefinition = {}, @relationDefinitions = {}) ->

        @definition = @getDefaultDefinition()
        @definition[k] = @customDefinition[k] for k, v of @customDefinition

        @setACL()

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
        JSON.stringify @toJSON(), null, 2


    ###*
    get definition of the model

    @method toJSON
    @private
    @return {Object} definition
    ###
    toJSON: ->

        return @definition


    ###*
    is model extend User?

    @private
    @return {Boolean}
    ###
    isUser: ->
        @definition.base is 'User'


    ###*
    set ACL to definition by aclType

    ###
    setACL: ->
        @aclType = @definition.aclType
        delete @definition.aclType

        if not @aclType and Array.isArray @definition.acls
            @aclType = 'custom'
            return

        @aclType ?= 'admin'
        @definition.acls = new AclGenerator(@aclType, @isUser(), @relationDefinitions).generate()


    ###*
    get default definition object

    @private
    ###
    getDefaultDefinition: ->
        name        : @modelName
        plural      : @modelName
        base        : "PersistedModel"
        idInjection : true
        properties  : {}
        validations : []
        relations   : {}



module.exports = ModelDefinition
