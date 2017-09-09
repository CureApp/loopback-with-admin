
module.exports = (app, cb) ->

    Installation = app.models.installation

    Installation.observe 'before save', (ctx, next) ->
        if ctx.instance
            ctx.instance.appId = 'loopback-with-admin'
        next()

    registerApp(app, cb)


###*
registers an application instance for push notification service

@method registerApp
###
registerApp = (app, cb) ->
    Application  = app.models.application

    config    = require('../push-credentials')
    buildInfo = require('../build-info')

    Application.observe 'before save', (ctx, next) ->
        ctx.instance.id = 'loopback-with-admin'
        next()

    Application.register(
        'CureApp, Inc.'
        'loopback-with-admin'
        {
            descriptions: ''
            pushSettings:
                apns:
                    production: buildInfo.env is 'production'
                    certData: config.apnsCertData
                    keyData: config.apnsKeyData

                    feeedbackOptions:
                        batchFeedback: true
                        interval: 300

                gcm:
                    serverApiKey: config.gcmServerApiKey

        }
        (err, savedApp) ->
            console.log err if err
            cb()
    )

