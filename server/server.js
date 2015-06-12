var loopback = require('loopback');
var boot = require('loopback-boot');

var app = module.exports = loopback();

app.start = function(callback) {
  boot(app, __dirname, function(err) {
    if (err) throw err;

      // start the web server
      app.listen(function() {
        app.emit('started');
        console.log('Web server listening at: %s', app.get('url'));
        if (callback) callback();
      });
  });
};

// Bootstrap the application, configure models, datasources and middleware.
// Sub-apps like REST API are mounted via boot scripts.

// start the server if `$ node server.js`
if (require.main === module) {
  app.start();
}
