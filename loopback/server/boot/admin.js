// http://docs.strongloop.com/display/public/LB/Creating+a+default+admin+user

module.exports = function(app, done) {

  // lwaTokenManager: instance of AdminTokenManager (src/server/admin-token-manager.coffee)
  // defined in LoopbackServer (src/lib/loopback-server.coffee)
  if (app.lwaTokenManager) {
    app.lwaTokenManager.init(app.models).then(function() {
      done()
    })
    .catch(function(err) {
      console.log(err)
      console.log(err.stack)
      process.exit()
    })
  }
  else {
    done()
  }
};
