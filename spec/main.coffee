
{ normalize } = require 'path'
{ mkdirSyncRecursive, rmdirSyncRecursive }  = require 'wrench'

Main = require '../src/main'
LoopbackProcessLauncher = require '../src/lib/loopback-process-launcher'
LoopbackServer = require '../src/lib/loopback-server'
Promise = require('es6-promise').Promise

modelDefinitions = {}

configDir = normalize __dirname + '/lib/music-live-configs'

describe 'Main', ->

    describe 'env', ->

        it 'is "development" by default', ->

            main = new Main(modelDefinitions, configDir)
            expect(main.env).to.equal 'development'


        it 'is set the same as environment variable "NODE_ENV" if set.', ->

            process.env.NODE_ENV = 'xxxx'

            main = new Main(modelDefinitions, configDir)
            expect(main.env).to.equal 'xxxx'

            process.env.NODE_ENV = ''


        it 'is set value from constructor if set.', ->
            process.env.NODE_ENV = 'xxxx'
            main = new Main(modelDefinitions, configDir, 'local')

            expect(main.env).to.equal 'local'
            process.env.NODE_ENV = ''


    describe 'generate', ->

        it 'invokes three generator\'s generate()', ->

            main = new Main(modelDefinitions, configDir)
            counter = 0
            generate = -> counter++
            main.configJSONGenerator = generate: generate
            main.modelsGenerator     = generate: generate
            main.buildInfoGenerator  = generate: generate

            main.generate()

            expect(counter).to.equal 3


        it 'returns generated contents', ->

            mkdirSyncRecursive(__dirname + '/main-test/config')
            mkdirSyncRecursive(__dirname + '/main-test/models')

            main = new Main(modelDefinitions, configDir)
            main.configJSONGenerator.destinationPath = __dirname + '/main-test/config'
            main.modelsGenerator.destinationDir = __dirname + '/main-test/models'
            main.modelsGenerator.modelConfigGenerator.destinationPath = __dirname + '/main-test/config'
            main.modelsGenerator.buildInfoGenerator = __dirname + '/main-test/config'

            generated = main.generate()

            expect(generated).to.have.property 'config'
            expect(generated).to.have.property 'buildInfo'
            expect(generated).to.have.property 'models'

            rmdirSyncRecursive __dirname + '/main-test'


    describe 'reset', ->

        it 'invokes three generator\'s reset()', ->

            main = new Main(modelDefinitions, configDir)
            counter = 0
            reset = -> counter++
            main.configJSONGenerator = reset: reset
            main.modelsGenerator     = reset: reset
            main.buildInfoGenerator  = reset: reset

            main.reset()

            expect(counter).to.equal 3


    describe '@launchLoopback', ->

        before ->

        after ->

        it 'launches loopback-server by default', (done) ->
            @launch = LoopbackServer::launch
            LoopbackServer::launch = =>
                LoopbackServer::launch = @launch
                done()

            Main.launchLoopback()


        it 'launches loopback-process-launcher when spawn is true', (done) ->
            @launch = LoopbackProcessLauncher::launch
            LoopbackProcessLauncher::launch = =>
                LoopbackProcessLauncher::launch = @launch
                done()

            spawn = true
            Main.launchLoopback(spawn)


    describe 'run', ->

        beforeEach ->
            @called = {}

            @reset = Main::reset
            @generate = Main::generate
            @launchLoopback = Main.launchLoopback

            Main::reset = => @called.reset = true
            Main::generate = => @called.generate = true
            Main.launchLoopback = => Promise.resolve @called.launchLoopback = true

        afterEach ->
            Main::reset = @reset
            Main::generate = @generate
            Main.launchLoopback = @launchLoopback

        it 'invokes reset() unless reset is false', ->

            Main.run(modelDefinitions, configDir)

            expect(@called.reset).to.be.true
            expect(@called.generate).to.be.true
            expect(@called.launchLoopback).to.be.true


        it 'does not invoke reset if reset is false', ->

            Main.run(modelDefinitions, configDir, reset: false)

            expect(@called.reset).not.to.exist
            expect(@called.generate).to.be.true
            expect(@called.launchLoopback).to.be.true

