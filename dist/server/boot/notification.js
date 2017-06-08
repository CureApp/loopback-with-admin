var config, createAPNsSettings, registerApp;

config = require('../push-credentials');

module.exports = function(app, cb) {
  var Installation;
  Installation = app.models.installation;
  Installation.observe('before save', function(ctx, next) {
    if (ctx.instance) {
      ctx.instance.appId = 'loopback-with-admin';
    }
    return next();
  });
  return registerApp(app, cb);
};


/**
create settings for apns

@method createAPNsSettings
 */

createAPNsSettings = function() {
  var buildInfo, commonSettings, keySettings;
  buildInfo = require('../build-info');
  commonSettings = {
    production: buildInfo.env === 'production',
    feeedbackOptions: {
      batchFeedback: true,
      interval: 300
    }
  };
  keySettings = {};
  if (config.useAPNsAuthKey) {
    keySettings = {
      token: {
        key: config.apnsTokenKeyPath,
        keyId: config.apns.apnsTokenKeyId,
        teamId: config.apnsTokenTeamId
      },
      bundle: config.apnsBundleId
    };
  } else {
    keySettings = {
      certData: config.apnsCertData,
      keyData: config.apnsKeyData
    };
  }
  return Object.assign(commonSettings, keySettings);
};


/**
registers an application instance for push notification service

@method registerApp
 */

registerApp = function(app, cb) {
  var Application;
  Application = app.models.application;
  Application.observe('before save', function(ctx, next) {
    ctx.instance.id = 'loopback-with-admin';
    return next();
  });
  return Application.register('CureApp, Inc.', 'loopback-with-admin', {
    descriptions: '',
    pushSettings: {
      apns: createAPNsSettings(),
      gcm: {
        serverApiKey: config.gcmServerApiKey
      }
    }
  }, function(err, savedApp) {
    if (err) {
      console.log(err);
    }
    return cb();
  });
};
