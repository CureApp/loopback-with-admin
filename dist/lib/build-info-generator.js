var BuildInfoGenerator, ConfigJSONGenerator, normalize,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

normalize = require('path').normalize;

ConfigJSONGenerator = require('./config-json-generator');

BuildInfoGenerator = (function(superClass) {
  extend(BuildInfoGenerator, superClass);

  BuildInfoGenerator.prototype.defaultConfigsPath = normalize(__dirname + "/../../default-values");

  BuildInfoGenerator.prototype.configNames = ['build-info'];


  /**
  @constructor
   */

  function BuildInfoGenerator(modelDefinitions, customConfigs, env) {
    this.modelDefinitions = modelDefinitions;
    this.customConfigs = customConfigs;
    this.env = env;
  }

  BuildInfoGenerator.prototype.getMergedConfig = function() {
    return {
      env: this.env,
      customConfigs: this.customConfigs,
      modelDefinitions: this.modelDefinitions,
      buildAt: new Date().toISOString()
    };
  };

  BuildInfoGenerator.prototype.generate = function() {
    var generated;
    generated = BuildInfoGenerator.__super__.generate.call(this);
    return generated['build-info'];
  };

  return BuildInfoGenerator;

})(ConfigJSONGenerator);

module.exports = BuildInfoGenerator;
