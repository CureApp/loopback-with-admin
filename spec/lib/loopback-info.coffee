
LoopbackInfo = require '../../src/lib/loopback-info'
Main = require '../../src/main'

{ mkdirSyncRecursive, rmdirSyncRecursive }  = require 'wrench'

lbProcess =
    kill: -> @cb()


domainDir = __dirname + '/domains/music-live'
configDir = __dirname + '/music-live-configs'
domain = require('base-domain').createInstance dirname: domainDir

describe 'LoopbackInfo', ->

    before ->
        env = 'xxxyyyzzz'
        main = new Main(domain, configDir, env)
        main.configJSONGenerator.destinationPath                  = __dirname + '/lbi-test/config'
        main.modelsGenerator.destinationDir                       = __dirname + '/lbi-test/models'
        main.modelsGenerator.modelConfigGenerator.destinationPath = __dirname + '/lbi-test/config'
        main.modelsGenerator.buildInfoGenerator                   = __dirname + '/lbi-test/config'

        mkdirSyncRecursive __dirname + '/lbi-test/config'
        mkdirSyncRecursive __dirname + '/lbi-test/models'

        @generated = main.generate()
        @lbInfo = new LoopbackInfo(lbProcess, @generated)

    after ->
        rmdirSyncRecursive __dirname + '/lbi-test'

    describe 'getURL', ->

        it 'returns URL with host, port and api root info', ->
            expect(@lbInfo.getURL()).to.equal('0.0.0.0:3000/api')


    describe 'getEnv', ->

        it 'returns environment in which main generated', ->
            expect(@lbInfo.getEnv()).to.equal 'xxxyyyzzz'


    describe 'getAccessToken', ->

        it 'returns access token of admin', ->
            expect(@lbInfo.getAccessToken()).to.equal '(you must set access token)'



    describe 'kill', ->

        it 'kills loopback process', (done) ->
            lbProcess.cb = done
            @lbInfo.kill()
