
var fs = require('fs')
var customRolesDir = __dirname + '/../custom-roles'

module.exports = function(app) {

  var Role = app.models.Role;

  fs.readdirSync(customRolesDir).forEach(function(filename) {

    if (filename.slice(-3) !== '.js') return;

    var fn = require(customRolesDir + '/' + filename)

    if (typeof fn !== 'function') return;

    var name = filename.slice(0, -3)

    Role.registerResolver(name, fn.bind(app))

  })
};
