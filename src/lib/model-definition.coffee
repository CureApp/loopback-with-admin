

AclGenerator = require './acl-generator'

class ModelDefinition

    constructor: (@Entity, @customDefinition = {}) ->

        @aclType = @customDefinition.aclType ? 'admin'

        @definition =
            name        : @getName()
            plural      : @getName()
            base        : "PersistedModel"
            idInjection : true
            properties  : {}
            validations : []

        @definition[k] = @customDefinition[k] for k, v of @customDefinition
        delete @definition.aclType


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
        @definition.acls      = @getACL()
        @definition.relations = @getRelations()

        return @definition


    ###*
    is model extend User?

    @private
    @return {Boolean}
    ###
    isUser: ->
        @definition.base is 'User'


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
        rels = {}
        propInfo = @Entity.getPropInfo()

        for prop in @Entity.getEntityProps()
            typeInfo = propInfo.dic[prop]

            rels[prop] =
                type       : 'belongsTo'
                model      : typeInfo.model
                foreignKey : typeInfo.idPropName

        return rels


module.exports = ModelDefinition
