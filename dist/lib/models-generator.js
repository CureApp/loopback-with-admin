var ModelConfigGenerator, ModelDefinition, ModelsGenerator, fs, normalize;

normalize = require('path').normalize;

fs = require('fs-extra');

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
    fs.mkdirsSync(this.destinationDir);
    modelNames = (function() {
      var ref, results;
      ref = this.definitions;
      results = [];
      for (name in ref) {
        definition = ref[name];
        results.push(this.generateJSONandJS(name, definition));
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
      fs.removeSync(this.destinationDir);
    }
    return this.modelConfigGenerator.reset();
  };


  /**
  
  @method generateBuiltinModels
  @private
   */

  ModelsGenerator.prototype.generateBuiltinModels = function() {
    var definition, ext, filename, i, len, modelName, ref, ref1, results;
    ref = fs.readdirSync(this.builtinDir);
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      filename = ref[i];
      ref1 = filename.split('.'), modelName = ref1[0], ext = ref1[1];
      definition = require(this.builtinDir + '/' + filename);
      results.push(this.generateJSONandJS(modelName, definition));
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

  ModelsGenerator.prototype.generateJSONandJS = function(modelName, modelDefinition) {
    var jsFilePath, jsonContent, jsonFilePath;
    jsonFilePath = normalize(this.destinationDir + "/" + modelName + ".json");
    jsFilePath = normalize(this.destinationDir + "/" + modelName + ".js");
    if (!(modelDefinition instanceof ModelDefinition)) {
      jsonContent = JSON.stringify(modelDefinition, null, 2);
      fs.writeFileSync(jsonFilePath, jsonContent);
      fs.writeFileSync(jsFilePath, this.getEmptyJSContent());
      return modelName;
    }
    jsonContent = modelDefinition.toStringifiedJSON();
    fs.writeFileSync(jsonFilePath, jsonContent);
    fs.writeFileSync(jsFilePath, this.getJSContent(modelDefinition.definition.validations));
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
  get js content
  
  @private
   */

  ModelsGenerator.prototype.getJSContent = function(validations) {
    var foot, head, i, len, prop, rules, validateMethods, validation;
    if (!validations) {
      return this.getEmptyJSContent();
    }
    validateMethods = [];
    for (i = 0, len = validations.length; i < len; i++) {
      validation = validations[i];
      for (prop in validation) {
        rules = validation[prop];
        if (rules.required) {
          validateMethods.push("  Model.validatesPresenceOf('" + prop + "');");
        }
        if (rules.pattern) {
          validateMethods.push("  Model.validatesFormatOf('" + prop + "', { with: /" + rules.pattern + "/ });");
        }
        if (rules.min) {
          validateMethods.push("  Model.validatesLengthOf('" + prop + "', { min: " + rules.min + " });");
        }
        if (rules.max) {
          validateMethods.push("  Model.validatesLengthOf('" + prop + "', { max: " + rules.max + " });");
        }
      }
    }
    head = 'module.exports = function(Model) {\n';
    foot = '\n};\n';
    return head + validateMethods.join('\n') + foot;
  };


  /**
  get RelationDefinition
  
  @private
   */

  ModelsGenerator.prototype.getRelationDefinitions = function(customModelDefinition, customModelDefinitions) {
    var definitions, ref, relationDefinition, relationName;
    definitions = {};
    ref = customModelDefinition.relations;
    for (relationName in ref) {
      relationDefinition = ref[relationName];
      if (!customModelDefinitions[relationName]) {
        continue;
      }
      switch (relationDefinition.type) {
        case 'hasMany':
          definitions[relationName] = {
            type: relationDefinition.type,
            aclType: customModelDefinitions[relationName].aclType
          };
      }
    }
    return definitions;
  };


  /**
  create ModelDefinition instances
  
  @private
   */

  ModelsGenerator.prototype.createModelDefinitions = function(customModelDefinitions) {
    var customModelDefinition, definitions, modelName, relationDefinitions;
    definitions = {};
    for (modelName in customModelDefinitions) {
      customModelDefinition = customModelDefinitions[modelName];
      if (customModelDefinition.relations != null) {
        relationDefinitions = this.getRelationDefinitions(customModelDefinition, customModelDefinitions);
      }
      definitions[modelName] = new ModelDefinition(modelName, customModelDefinition, relationDefinitions);
    }
    return definitions;
  };

  return ModelsGenerator;

})();

module.exports = ModelsGenerator;
