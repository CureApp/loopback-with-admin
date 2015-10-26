var CustomConfigs, fs;

fs = require('fs');

CustomConfigs = (function() {
  function CustomConfigs(configs, env) {
    var configDir;
    if (configs == null) {
      configs = {};
    }
    if (typeof configs === 'string') {
      configDir = configs;
      this.configs = this.loadDir(configDir, env);
    } else {
      this.configs = this.clone(configs);
      delete this.configs.models;
    }
  }

  CustomConfigs.prototype.toObject = function() {
    return this.clone(this.configs);
  };

  CustomConfigs.prototype.loadDir = function(configDir, env) {
    var configs;
    configs = this.loadEnvDir(configDir, env);
    this.appendCommonConfigs(configDir, configs);
    return configs;
  };

  CustomConfigs.prototype.loadEnvDir = function(configDir, env) {
    var configFile, configName, configs, envDir, ext, i, len, ref, ref1;
    configs = {};
    envDir = configDir + "/" + env;
    if (!env || !fs.existsSync(envDir)) {
      return configs;
    }
    ref = fs.readdirSync(envDir);
    for (i = 0, len = ref.length; i < len; i++) {
      configFile = ref[i];
      ref1 = configFile.split('.'), configName = ref1[0], ext = ref1[1];
      if (ext === 'coffee' || ext === 'js' || ext === 'json') {
        configs[configName] = require(envDir + '/' + configFile);
      }
    }
    return configs;
  };

  CustomConfigs.prototype.appendCommonConfigs = function(configDir, configs) {
    var commonDir, configFile, configName, ext, i, len, ref, ref1, results;
    commonDir = configDir + "/common";
    if (!fs.existsSync(commonDir)) {
      return;
    }
    ref = fs.readdirSync(commonDir);
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      configFile = ref[i];
      ref1 = configFile.split('.'), configName = ref1[0], ext = ref1[1];
      if (ext === 'coffee' || ext === 'js' || ext === 'json') {
        results.push(configs[configName] != null ? configs[configName] : configs[configName] = require(commonDir + '/' + configFile));
      } else {
        results.push(void 0);
      }
    }
    return results;
  };

  CustomConfigs.prototype.clone = function(obj) {
    var k, v;
    for (k in obj) {
      v = obj[k];
      if ((v != null) && typeof v === 'object') {
        obj[k] = this.clone(v);
      } else {
        obj[k] = v;
      }
    }
    return obj;
  };

  return CustomConfigs;

})();

module.exports = CustomConfigs;
