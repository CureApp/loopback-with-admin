
{ normalize } = require 'path'
fs = require 'fs-extra'

Main = require '../src/main'
LoopbackServer = require '../src/lib/loopback-server'

modelDefinitions = {}

configDir = normalize __dirname + '/lib/music-live-configs'

describe 'Main', ->

    describe 'env', ->

        it 'is "development" by default', ->

            main = new Main(modelDefinitions, configDir)
            assert main.env is 'development'


        it 'is set the same as environment variable "NODE_ENV" if set.', ->

            process.env.NODE_ENV = 'xxxx'

            main = new Main(modelDefinitions, configDir)
            assert main.env is 'xxxx'

            process.env.NODE_ENV = ''


        it 'is set value from constructor if set.', ->
            process.env.NODE_ENV = 'xxxx'
            main = new Main(modelDefinitions, configDir, 'local')

            assert main.env is 'local'
            process.env.NODE_ENV = ''


    describe 'generate', ->

        it 'invokes four generator\'s generate()', ->

            main = new Main(modelDefinitions, configDir)
            counter = 0
            generate = -> counter++
            main.configJSONGenerator = generate: generate
            main.modelsGenerator     = generate: generate
            main.buildInfoGenerator  = generate: generate
            main.bootGenerator       = generate: generate

            main.generate()

            assert counter is 4


        it 'returns generated contents', ->

            fs.mkdirsSync(__dirname + '/main-test/config')
            fs.mkdirsSync(__dirname + '/main-test/models')

            main = new Main(modelDefinitions, configDir)
            main.configJSONGenerator.destinationPath = __dirname + '/main-test/config'
            main.modelsGenerator.destinationDir = __dirname + '/main-test/models'
            main.modelsGenerator.modelConfigGenerator.destinationPath = __dirname + '/main-test/config'
            main.modelsGenerator.buildInfoGenerator = __dirname + '/main-test/config'

            generated = main.generate()

            assert generated.hasOwnProperty('config')
            assert generated.hasOwnProperty('buildInfo')
            assert generated.hasOwnProperty('models')
            assert generated.hasOwnProperty('bootInfo')

            fs.removeSync __dirname + '/main-test'


    describe 'reset', ->

        it 'invokes four generator\'s reset()', ->

            main = new Main(modelDefinitions, configDir)
            counter = 0
            reset = -> counter++
            main.configJSONGenerator = reset: reset
            main.modelsGenerator     = reset: reset
            main.buildInfoGenerator  = reset: reset
            main.bootGenerator       = reset: reset

            main.reset()

            assert counter is 4


    describe '@run', ->

        beforeEach ->
            @called = {}

            @reset = Main::reset
            @generate = Main::generate
            @launchLoopback = Main.launchLoopback

            Main::reset = => @called.reset = true
            Main::generate = => @called.generate = true
            Main.launchLoopback = (params) => Promise.resolve @called.launchLoopback = true

        afterEach ->
            Main::reset = @reset
            Main::generate = @generate
            Main.launchLoopback = @launchLoopback

        it 'invokes reset() unless reset is false', ->

            Main.run(modelDefinitions, configDir)

            assert @called.reset is true
            assert @called.generate is true
            assert @called.launchLoopback is true


        it 'does not invoke reset if reset is false', ->

            Main.run(modelDefinitions, configDir, reset: false)

            assert not @called.reset?
            assert @called.generate is true
            assert @called.launchLoopback is true


        it 'invokes launchLoopback with `admin` options', ->

            adminOptions =
                id: 'admin-1234'
                email: 'i-am-admin@example.com'
                password: 'administrator'
                intervalHours: 12

            params = null

            Main.launchLoopback = (_, p, __) =>
                params = p
                Promise.resolve @called.launchLoopback = true

            Main.run(modelDefinitions, configDir, admin: adminOptions)

            assert @called.reset is true
            assert @called.generate is true
            assert @called.launchLoopback is true
            assert params is adminOptions

