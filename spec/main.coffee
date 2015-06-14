
{ normalize } = require 'path'

Main = require '../src/main'

domainDir = normalize __dirname + '/lib/domains/music-live'
domain = require('base-domain').createInstance dirname: domainDir

configDir = normalize __dirname + '/lib/music-live-configs'

describe 'Main', ->

    describe 'env', ->

        it 'is "development" by default', ->

            main = new Main(domain, configDir)
            expect(main.env).to.equal 'development'


        it 'is set the same as environment variable "NODE_ENV" if set.', ->

            process.env.NODE_ENV = 'xxxx'

            main = new Main(domain, configDir)
            expect(main.env).to.equal 'xxxx'

            process.env.NODE_ENV = ''


        it 'is set value from constructor if set.', ->
            process.env.NODE_ENV = 'xxxx'
            main = new Main(domain, configDir, 'local')

            expect(main.env).to.equal 'local'
            process.env.NODE_ENV = ''


    describe 'loadModelDefinitions', ->

        it 'returns custom model-definitions object', ->

            definitions = new Main(domain, configDir).loadModelDefinitions()

            expect(definitions).to.have.property 'player'
            expect(definitions.player).to.have.property 'base', 'User'

            expect(definitions).to.have.property 'instrument'
            expect(definitions.instrument).to.have.property 'aclType', 'owner'


    describe 'generate', ->

        it 'invokes three generator\'s generate()', ->

            main = new Main(domain, configDir)
            counter = 0
            generate = -> counter++
            main.configJSONGenerator = generate: generate
            main.modelsGenerator     = generate: generate
            main.buildInfoGenerator  = generate: generate

            main.generate()

            expect(counter).to.equal 3


    describe 'reset', ->

        it 'invokes three generator\'s reset()', ->

            main = new Main(domain, configDir)
            counter = 0
            reset = -> counter++
            main.configJSONGenerator = reset: reset
            main.modelsGenerator     = reset: reset
            main.buildInfoGenerator  = reset: reset

            main.reset()

            expect(counter).to.equal 3


    xdescribe '@startLoopback', ->

        it 'spawns loopback process', (done) ->
            @timeout 30000

            main = new Main(domain, configDir).generate()

            Main.startLoopback().then ->
                console.log "then"
                done()
            .catch done


    describe 'runWithDomain', ->

