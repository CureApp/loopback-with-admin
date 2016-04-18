var ConfigJSONGenerator, fs, normalize,
  hasProp = {}.hasOwnProperty;

normalize = require('path').normalize;

fs = require('fs');

ConfigJSONGenerator = (function() {
  ConfigJSONGenerator.prototype.defaultConfigsPath = normalize(__dirname + "/../../default-values/non-model-configs");

  ConfigJSONGenerator.prototype.destinationPath = normalize(__dirname + "/../../loopback/server");

  ConfigJSONGenerator.prototype.configNames = ['datasources', 'middleware', 'server', 'push-credentials'];


  /**
  default-configs/server.json will be server/config.json
  
  @property destinationNamePairs
  @private
   */

  ConfigJSONGenerator.prototype.destinationNamePairs = {
    server: 'config'
  };


  /**
  
  @constructor
  @param {Object} customConfigObj
  @param {String} env
   */

  function ConfigJSONGenerator(customConfigObj, env) {
    this.customConfigObj = customConfigObj != null ? customConfigObj : {};
  }


  /**
  generate JSON files into server dir
  
  @method generate
  @public
  @return {Object} generatedContents
   */

  ConfigJSONGenerator.prototype.generate = function() {
    var config, configName, generatedContents, i, len, path, ref;
    generatedContents = {};
    ref = this.configNames;
    for (i = 0, len = ref.length; i < len; i++) {
      configName = ref[i];
      config = this.getMergedConfig(configName);
      path = this.getDestinationPathByName(configName);
      fs.writeFileSync(path, JSON.stringify(config, null, 2));
      generatedContents[configName] = config;
    }
    return generatedContents;
  };


  /**
  remove previously-generated JSON files
  
  @method reset
  @public
   */

  ConfigJSONGenerator.prototype.reset = function() {
    var configName, i, len, path, ref, results;
    ref = this.configNames;
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      configName = ref[i];
      path = this.getDestinationPathByName(configName);
      if (fs.existsSync(path)) {
        results.push(fs.unlinkSync(path));
      } else {
        results.push(void 0);
      }
    }
    return results;
  };


  /**
  new config path
   */

  ConfigJSONGenerator.prototype.getDestinationPathByName = function(configName) {
    var filename, ref;
    filename = (ref = this.destinationNamePairs[configName]) != null ? ref : configName;
    return normalize(this.destinationPath + '/' + filename + '.json');
  };


  /**
  merge custom and default for each config names
  
  @private
   */

  ConfigJSONGenerator.prototype.getMergedConfig = function(configName) {
    var customConfig, defaultConfig;
    defaultConfig = this.loadDefaultConfig(configName);
    customConfig = this.customConfigObj[configName];
    return this.merge(customConfig, defaultConfig);
  };


  /**
  merge two objects into one new object
  object at 1st argument overrides that at 2nd
  
  @param {Object} dominant
  @param {Object} base
  @return {Object} merged
  @private
   */

  ConfigJSONGenerator.prototype.merge = function(dominant, base) {
    var k, merged, sub, v;
    if (dominant == null) {
      dominant = {};
    }
    if (base == null) {
      base = {};
    }
    merged = {};
    for (k in base) {
      if (!hasProp.call(base, k)) continue;
      v = base[k];
      merged[k] = v;
    }
    for (k in dominant) {
      if (!hasProp.call(dominant, k)) continue;
      sub = dominant[k];
      if ((merged[k] != null) && typeof merged[k] === 'object' && (v != null)) {
        merged[k] = this.merge(sub, merged[k]);
      } else {
        merged[k] = sub;
      }
    }
    return merged;
  };


  /**
  load default config JSON files
  
  @private
   */

  ConfigJSONGenerator.prototype.loadDefaultConfig = function(configName) {
    var e, error;
    try {
      return require(this.defaultConfigsPath + "/" + configName + ".json");
    } catch (error) {
      e = error;
      return null;
    }
  };

  return ConfigJSONGenerator;

})();

module.exports = ConfigJSONGenerator;
