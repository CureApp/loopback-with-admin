// http://docs.strongloop.com/display/public/LB/Creating+a+default+admin+user

var HUNDRED_YEARS = 60 * 60 * 24 * 365 * 100;

var adminInfo    = require('../admin.json');
var adminAccount = adminInfo.account;
var adminId      = adminInfo.id;
var adminToken   = adminInfo.accessToken;


var exit = function(err) {
  console.error('%j', err);
  process.exit();
};

module.exports = function(app, done) {

  var User        = app.models.User;
  var Role        = app.models.Role;
  var RoleMapping = app.models.RoleMapping;
  var AccessToken = app.models.AccessToken;

  User.settings.maxTTL = HUNDRED_YEARS;

  // creates admin role and attach it to admin user
  var createAdminRole = function(err, user) {
    if (err) return exit(err);


    //create the admin role
    Role.create({
      name: 'admin'
    }, function(err, role) {
      if (err) return exit(err);

      //set admin role to admin user
      role.principals.create({
        principalType: RoleMapping.USER,
        principalId: user.id
      }, function(err, principal) {
        if (err) return exit(err);

        setAccessToken();
      });
    });
  };

  // set access token of the admin
  var setAccessToken = function() {

    // check existence of admin access token
    AccessToken.exists(adminToken, function(err, exists) {
      if (err) return exit(err);

      if (exists === true) return done();

      // if no admin access token, then create
      var loginInfo = {
        email    : adminAccount.email,
        password : adminAccount.password,
        ttl      : HUNDRED_YEARS
      };


      AccessToken.observe('before save', function(ctx, next) {
        ctx.instance.id = adminToken;
        next();
      });


      User.login(loginInfo, function(err, result) {
          AccessToken._observers['before save'].pop() // unobserve
          done(err);
      });
    });
  };


  var accountForCreation = {
    id       : adminId,
    email    : adminAccount.email,
    password : adminAccount.password,
  };


  User.create(accountForCreation, createAdminRole);

};
