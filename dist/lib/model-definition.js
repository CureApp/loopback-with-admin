var AclGenerator, ModelDefinition;

AclGenerator = require('./acl-generator');


/**
@class ModelDefinition
 */

ModelDefinition = (function() {
  function ModelDefinition(modelName, customDefinition, relationDefinitions) {
    var k, ref, v;
    this.modelName = modelName;
    this.customDefinition = customDefinition != null ? customDefinition : {};
    this.relationDefinitions = relationDefinitions != null ? relationDefinitions : {};
    this.definition = this.getDefaultDefinition();
    ref = this.customDefinition;
    for (k in ref) {
      v = ref[k];
      this.definition[k] = this.customDefinition[k];
    }
    this.setACL();
  }


  /**
  get model name
  
  @method getName
  @public
  @return {String} modelName
   */

  ModelDefinition.prototype.getName = function() {
    return this.Entity.getName();
  };


  /**
  get stringified JSON contents about the model
  
  @method toStringifiedJSON
  @public
  @return {String} stringifiedJSON
   */

  ModelDefinition.prototype.toStringifiedJSON = function() {
    return JSON.stringify(this.toJSON(), null, 2);
  };


  /**
  get definition of the model
  
  @method toJSON
  @private
  @return {Object} definition
   */

  ModelDefinition.prototype.toJSON = function() {
    return this.definition;
  };


  /**
  is model extend User?
  
  @private
  @return {Boolean}
   */

  ModelDefinition.prototype.isUser = function() {
    return this.definition.base === 'User';
  };


  /**
  set ACL to definition by aclType
   */

  ModelDefinition.prototype.setACL = function() {
    this.aclType = this.definition.aclType;
    delete this.definition.aclType;
    if (!this.aclType && Array.isArray(this.definition.acls)) {
      this.aclType = 'custom';
      return;
    }
    if (this.aclType == null) {
      this.aclType = 'admin';
    }
    return this.definition.acls = new AclGenerator(this.aclType, this.isUser(), this.relationDefinitions).generate();
  };


  /**
  get default definition object
  
  @private
   */

  ModelDefinition.prototype.getDefaultDefinition = function() {
    return {
      name: this.modelName,
      plural: this.modelName,
      base: "PersistedModel",
      idInjection: true,
      properties: {},
      validations: [],
      relations: {}
    };
  };

  return ModelDefinition;

})();

module.exports = ModelDefinition;
