
###*
@class EmptyModelDefinition
@extends ModelDefinition
###
ModelDefinition = require './model-definition'

class EmptyModelDefinition extends ModelDefinition

    constructor: (@name, customDefinition = {}) ->
        super(null, customDefinition)

    getName           : -> @name
    getEntityPropInfo : -> {}
    getACL            : -> []
    getRelations      : -> {}


module.exports = EmptyModelDefinition
