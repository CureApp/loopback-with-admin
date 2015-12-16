var BuildInfoGenerator, ConfigJSONGenerator, CustomConfigs, LoopbackInfo, LoopbackProcessLauncher, LoopbackServer, Main, ModelsGenerator, normalize;

normalize = require('path').normalize;

LoopbackProcessLauncher = require('./lib/loopback-process-launcher');

LoopbackInfo = require('./lib/loopback-info');

LoopbackServer = require('./lib/loopback-server');

ConfigJSONGenerator = require('./lib/config-json-generator');

ModelsGenerator = require('./lib/models-generator');

BuildInfoGenerator = require('./lib/build-info-generator');

CustomConfigs = require('./lib/custom-configs');


/**
entry point

@class Main
 */

Main = (function() {

  /**
  entry point.
  run loopback with model definitions, config
  
  @method run
  @public
  @static
  @param {Object} modelDefinitions
  @param {Object|String} [config] config object or config directory containing config info
  @param {Boolean} [options.reset] reset previously-generated settings before generation
  @param {String} [options.env] set environment (production|development|...)
  @param {Boolean} [options.spawn] if true, spawns child process of loopback
  return {Promise(LoopbackInfo)}
   */
  Main.run = function(modelDefinitions, config, options) {
    var generated, main;
    if (options == null) {
      options = {};
    }
    main = new this(modelDefinitions, config, options.env);
    if (options.reset !== false) {
      main.reset();
    }
    generated = main.generate();
    return this.launchLoopback(options.spawn).then((function(_this) {
      return function(server) {
        return new LoopbackInfo(server, generated);
      };
    })(this));
  };


  /**
  @constructor
  @private
   */

  function Main(modelDefinitions1, configs, env) {
    var configObj, customConfigs;
    this.modelDefinitions = modelDefinitions1;
    this.env = env;
    if (this.env == null) {
      this.env = process.env.NODE_ENV || 'development';
    }
    customConfigs = new CustomConfigs(configs, this.env);
    configObj = customConfigs.toObject();
    this.configJSONGenerator = new ConfigJSONGenerator(configObj, this.env);
    this.modelsGenerator = new ModelsGenerator(this.modelDefinitions);
    this.buildInfoGenerator = new BuildInfoGenerator(this.modelDefinitions, configObj, this.env);
  }


  /**
  @private
   */

  Main.prototype.generate = function() {
    return {
      config: this.configJSONGenerator.generate(),
      models: this.modelsGenerator.generate(),
      buildInfo: this.buildInfoGenerator.generate()
    };
  };


  /**
  @private
   */

  Main.prototype.reset = function() {
    this.configJSONGenerator.reset();
    this.modelsGenerator.reset();
    return this.buildInfoGenerator.reset();
  };


  /**
  run loopback
  
  @private
   */

  Main.launchLoopback = function(spawnChildProcess) {
    if (spawnChildProcess) {
      return new LoopbackProcessLauncher().launch();
    } else {
      return new LoopbackServer().launch();
    }
  };

  return Main;

})();

module.exports = Main;
