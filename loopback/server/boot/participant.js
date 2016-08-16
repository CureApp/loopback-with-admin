// http://docs.strongloop.com/display/public/LB/Creating+a+default+admin+user

module.exports = function(app, done) {

  if (app.participantTokenSetter) {
    app.participantTokenSetter.set(app.models).then(function() {
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
