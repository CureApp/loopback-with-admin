

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

        @definition.acls      ?= @getACL()
        @definition.relations ?= @getRelations()


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
    get ACL by aclType

    @private
    ###
    getACL: ->
        new AclGenerator(@aclType, @isUser()).generate()



    ###*
    get property info of sub-entities

    @method getEntityPropInfo
    ###
    getEntityPropInfo: ->
        info = {}
        propInfo = @Entity.getPropInfo()

        for prop in @Entity.getEntityProps()
            info[prop] = propInfo.dic[prop]

        return info


    ###*
    get "belongsTo" relations

    @private
    ###
    getRelations: ->
        rels = {}
        for prop, typeInfo of @getEntityPropInfo()

            rels[prop] =
                type       : 'belongsTo'
                model      : typeInfo.model
                foreignKey : typeInfo.idPropName

        return rels


    ###*
    set "hasMany" relations

    @method setHasManyRelation
    @param {String} relModel
    ###
    setHasManyRelation: (relModel) ->
        rel =
            type       : 'hasMany'
            model      : relModel
            foreignKey : ''

        @definition.relations[relModel] = rel


module.exports = ModelDefinition
