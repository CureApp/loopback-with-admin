var LoopbackProcessLauncher, LoopbackServer,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

require('es6-promise').polyfill();

LoopbackServer = require('./loopback-server');


/**
launches child process for loopback server

@class LoopbackProcessLauncher
 */

LoopbackProcessLauncher = (function(superClass) {
  extend(LoopbackProcessLauncher, superClass);

  function LoopbackProcessLauncher(options) {
    this.options = options != null ? options : {};
  }

  LoopbackProcessLauncher.prototype.launch = function() {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        _this.lbProcess = require('child_process').spawn('node', [_this.entryPath]);
        _this.lbProcess.stdout.setEncoding('utf8');
        _this.lbProcess.stderr.pipe(process.stderr);
        _this.rejectOnFailure(reject);
        _this.rejectOnTimeout(reject);
        return _this.resolveOnStarted(resolve);
      };
    })(this));
  };

  LoopbackProcessLauncher.prototype.rejectOnFailure = function(reject) {
    this.lbProcess.on('exit', function(code) {
      return reject(new Error("process exit with error code " + code));
    });
    return this.lbProcess.on('error', (function(_this) {
      return function(e) {
        _this.lbProcess.kill();
        return reject(new Error(e));
      };
    })(this));
  };

  LoopbackProcessLauncher.prototype.rejectOnTimeout = function(reject) {
    return this.timer = setTimeout((function(_this) {
      return function() {
        _this.lbProcess.kill();
        return reject(new Error('timeout after 30sec'));
      };
    })(this), 30 * 1000);
  };

  LoopbackProcessLauncher.prototype.removeListeners = function() {
    clearTimeout(this.timer);
    this.lbProcess.removeAllListeners();
    return this.lbProcess.stdout.removeAllListeners();
  };

  LoopbackProcessLauncher.prototype.resolveOnStarted = function(resolve) {
    var prevChunk;
    prevChunk = '';
    return this.lbProcess.stdout.on('data', (function(_this) {
      return function(chunk) {
        var data;
        data = prevChunk + chunk;
        if (data.match('LOOPBACK_WITH_ADMIN_STARTED')) {
          _this.removeListeners();
          resolve(_this.lbProcess);
        }
        return prevChunk = chunk;
      };
    })(this));
  };

  return LoopbackProcessLauncher;

})(LoopbackServer);

module.exports = LoopbackProcessLauncher;
