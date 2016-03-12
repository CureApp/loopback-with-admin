var LoopbackBootGenerator, fs, normalize;

normalize = require('path').normalize;

fs = require('fs');

LoopbackBootGenerator = (function() {
  LoopbackBootGenerator.dirpath = normalize(__dirname + '/../../loopback/server/custom-roles');

  function LoopbackBootGenerator(params) {
    if (params == null) {
      params = {};
    }
    this.customRoles = params.customRoles;
  }

  LoopbackBootGenerator.prototype.generate = function() {
    var filepath, name, ref;
    if (!this.customRoles) {
      return null;
    }
    ref = this.customRoles;
    for (name in ref) {
      filepath = ref[name];
      if (!fs.existsSync(filepath)) {
        delete this.customRoles[name];
      } else {
        fs.writeFileSync(this.constructor.dirpath + '/' + name + '.js', fs.readFileSync(filepath));
      }
    }
    return {
      customRoles: this.customRoles
    };
  };

  LoopbackBootGenerator.prototype.reset = function() {
    var filename, i, len, ref, results;
    ref = fs.readdirSync(this.constructor.dirpath);
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      filename = ref[i];
      if (filename.slice(-3) === '.js') {
        results.push(fs.unlinkSync(this.constructor.dirpath + '/' + filename));
      }
    }
    return results;
  };

  return LoopbackBootGenerator;

})();

module.exports = LoopbackBootGenerator;
