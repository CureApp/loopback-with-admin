config    = require('../push-credentials')

module.exports = (app, cb) ->

    Installation = app.models.installation

    Installation.observe 'before save', (ctx, next) ->
        if ctx.instance
            ctx.instance.appId = 'loopback-with-admin'
        next()

    registerApp(app, cb)


###*
create settings for apns

@method createAPNsSettings
###
createAPNsSettings = ->

    buildInfo = require('../build-info')

    commonSettings =
        production: buildInfo.env is 'production'
        feeedbackOptions:
            batchFeedback: true
            interval: 300

    keySettings = {}

    if config.useAPNsAuthKey
        keySettings =
            token: {
                key: config.apnsTokenKeyPath
                keyId: config.apns.apnsTokenKeyId
                teamId: config.apnsTokenTeamId
            }
            bundle: config.apnsBundleId

    else
        keySettings = {
            certData: config.apnsCertData
            keyData: config.apnsKeyData
        }

    return Object.assign(commonSettings, keySettings)


###*
registers an application instance for push notification service

@method registerApp
###
registerApp = (app, cb) ->

    Application  = app.models.application

    Application.observe 'before save', (ctx, next) ->
        ctx.instance.id = 'loopback-with-admin'
        next()

    Application.register(
        'CureApp, Inc.'
        'loopback-with-admin'
        {
            descriptions: ''
            pushSettings:
                apns: createAPNsSettings()
                gcm:
                    serverApiKey: config.gcmServerApiKey
        }
        (err, savedApp) ->
            console.log err if err
            cb()
    )
