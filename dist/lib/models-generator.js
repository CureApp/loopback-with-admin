var ModelConfigGenerator, ModelDefinition, ModelsGenerator, fs, mkdirSyncRecursive, normalize, ref, rmdirSyncRecursive;

normalize = require('path').normalize;

fs = require('fs');

ref = require('wrench'), mkdirSyncRecursive = ref.mkdirSyncRecursive, rmdirSyncRecursive = ref.rmdirSyncRecursive;

ModelDefinition = require('./model-definition');

ModelConfigGenerator = require('./model-config-generator');

ModelsGenerator = (function() {
  ModelsGenerator.prototype.destinationDir = normalize(__dirname + "/../../loopback/common/models");

  ModelsGenerator.prototype.builtinDir = normalize(__dirname + "/../../default-values/models");


  /**
  @param {Object} customModelDefinitions model definition data, compatible with loopback's model-config.json and aclType
   */

  function ModelsGenerator(customModelDefinitions) {
    var entityNames;
    this.definitions = this.createModelDefinitions(customModelDefinitions);
    entityNames = Object.keys(this.definitions);
    this.modelConfigGenerator = new ModelConfigGenerator(entityNames);
  }


  /**
  generate model-config.json and model definition files
  
  @method generate
  @public
  @return {Object} generatedInfo
   */

  ModelsGenerator.prototype.generate = function() {
    var modelConfig, modelNames;
    modelConfig = this.generateModelConfig();
    modelNames = this.generateDefinitionFiles();
    return {
      config: modelConfig,
      names: modelNames
    };
  };


  /**
  generate JSON files with empty js files into common/models
  
  @method generateDefinitionFiles
  @return {Array} generatedModelNames
   */

  ModelsGenerator.prototype.generateDefinitionFiles = function() {
    var builtinModelNames, definition, modelNames, name;
    mkdirSyncRecursive(this.destinationDir);
    modelNames = (function() {
      var ref1, results;
      ref1 = this.definitions;
      results = [];
      for (name in ref1) {
        definition = ref1[name];
        results.push(this.generateJSONandJS(name, definition.toStringifiedJSON()));
      }
      return results;
    }).call(this);
    builtinModelNames = this.generateBuiltinModels();
    return modelNames.concat(builtinModelNames);
  };


  /**
  reset
  
  @method reset
  @public
  @return
   */

  ModelsGenerator.prototype.reset = function() {
    if (fs.existsSync(this.destinationDir)) {
      rmdirSyncRecursive(this.destinationDir);
    }
    return this.modelConfigGenerator.reset();
  };


  /**
  
  @method generateBuiltinModels
  @private
   */

  ModelsGenerator.prototype.generateBuiltinModels = function() {
    var definition, ext, filename, i, len, modelName, ref1, ref2, results;
    ref1 = fs.readdirSync(this.builtinDir);
    results = [];
    for (i = 0, len = ref1.length; i < len; i++) {
      filename = ref1[i];
      ref2 = filename.split('.'), modelName = ref2[0], ext = ref2[1];
      definition = require(this.builtinDir + '/' + filename);
      results.push(this.generateJSONandJS(modelName, JSON.stringify(definition, null, 2)));
    }
    return results;
  };


  /**
  @method generateModelConfig
  @private
   */

  ModelsGenerator.prototype.generateModelConfig = function() {
    return this.modelConfigGenerator.generate();
  };


  /**
  generate JSON file and JS file of modelName
  
  @private
  @reurn {String} modelName
   */

  ModelsGenerator.prototype.generateJSONandJS = function(modelName, jsonContent) {
    var jsFilePath, jsonFilePath;
    jsonFilePath = normalize(this.destinationDir + "/" + modelName + ".json");
    fs.writeFileSync(jsonFilePath, jsonContent);
    jsFilePath = normalize(this.destinationDir + "/" + modelName + ".js");
    fs.writeFileSync(jsFilePath, this.getEmptyJSContent());
    return modelName;
  };


  /**
  get empty js content
  
  @private
   */

  ModelsGenerator.prototype.getEmptyJSContent = function() {
    return 'module.exports = function(Model) {};';
  };


  /**
  create ModelDefinition instances
  
  @private
   */

  ModelsGenerator.prototype.createModelDefinitions = function(customModelDefinitions) {
    var customModelDefinition, definitions, modelName;
    definitions = {};
    for (modelName in customModelDefinitions) {
      customModelDefinition = customModelDefinitions[modelName];
      definitions[modelName] = new ModelDefinition(modelName, customModelDefinition);
    }
    return definitions;
  };

  return ModelsGenerator;

})();

module.exports = ModelsGenerator;
