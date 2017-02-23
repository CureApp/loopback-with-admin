var ConfigJSONGenerator, ModelConfigGenerator, normalize,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

normalize = require('path').normalize;

ConfigJSONGenerator = require('./config-json-generator');

ModelConfigGenerator = (function(superClass) {
  extend(ModelConfigGenerator, superClass);

  ModelConfigGenerator.prototype.defaultConfigsPath = normalize(__dirname + "/../../default-values");

  ModelConfigGenerator.prototype.configNames = ['model-config'];


  /**
  @constructor
   */

  function ModelConfigGenerator(entityNames) {
    if (entityNames == null) {
      entityNames = [];
    }
    this.customConfigObj = {
      'model-config': this.getConfigByEntityNames(entityNames)
    };
  }

  ModelConfigGenerator.prototype.generate = function() {
    var generated;
    generated = ModelConfigGenerator.__super__.generate.call(this);
    return generated['model-config'];
  };


  /**
  get config object by entity names
  @private
  @param {Array(String)} entityNames
   */

  ModelConfigGenerator.prototype.getConfigByEntityNames = function(entityNames) {
    var config, entityName, i, len;
    if (entityNames == null) {
      entityNames = [];
    }
    config = {};
    for (i = 0, len = entityNames.length; i < len; i++) {
      entityName = entityNames[i];
      config[entityName] = {
        dataSource: 'db',
        "public": true
      };
    }
    return config;
  };

  return ModelConfigGenerator;

})(ConfigJSONGenerator);

module.exports = ModelConfigGenerator;
