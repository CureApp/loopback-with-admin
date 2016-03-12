
LoopbackInfo = require '../../src/lib/loopback-info'
Main = require '../../src/main'

{ mkdirSyncRecursive, rmdirSyncRecursive }  = require 'wrench'

lbProcess =
    kill: -> @cb()


configDir = __dirname + '/music-live-configs'

modelDefinitions = {}


describe 'LoopbackInfo', ->

    before ->
        env = 'xxxyyyzzz'
        main = new Main(modelDefinitions, configDir, env)
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
            assert @lbInfo.getURL() is('localhost:3000/api')


    describe 'getEnv', ->

        it 'returns environment in which main generated', ->
            assert @lbInfo.getEnv() is 'xxxyyyzzz'


    describe 'getAccessToken', ->

        it 'returns access token of admin', ->
            assert @lbInfo.getAccessToken() is '(you must set access token)'



    describe 'kill', ->

        it 'kills loopback process', (done) ->
            lbProcess.cb = done
            @lbInfo.kill()
