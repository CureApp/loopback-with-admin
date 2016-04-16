var loopback = require('loopback');
var boot = require('loopback-boot');

var app = module.exports = loopback();

app.start = function(callback) {
  boot(app, __dirname, function(err) {
    if (err) return callback(err)

      // start the web server
      app.listen(function(err) {

        if (err) return callback(err)

        app.emit('started');
        console.log('Web server listening at: %s', app.get('url'));

        console.log('LOOPBACK_WITH_ADMIN_STARTED');

        callback()
      });
  });
};

// Bootstrap the application, configure models, datasources and middleware.
// Sub-apps like REST API are mounted via boot scripts.

// start the server if `$ node server.js`
if (require.main === module) {
  app.start();
}
