

AclGenerator = require './acl-generator'

class ModelSetting

    constructor: (@Entity, @customSetting = {}) ->

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

    @private
    ###
    toJSON: ->
        json =
            name        : @getName()
            plural      : @getName()
            base        : "User"
            idInjection : true
            properties  : {}
            validations : []
            acls        : @getACL()


    getACL: ->
        new AclGenerator(@aclType, @isUser).generate()



module.exports = ModelSetting
