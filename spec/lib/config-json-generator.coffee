
{ normalize } = require 'path'

fs = require 'fs'

ConfigJSONGenerator = require '../../src/lib/config-json-generator'


describe 'ConfigJSONGenerator', ->


    describe 'getDestinationPathByName', ->

        before ->
            @generator = new ConfigJSONGenerator()

        it 'returns #{configName}.json', ->
            path = @generator.getDestinationPathByName('admin')
            expect(path).to.equal normalize __dirname + '/../../loopback/server/admin.json'


        it 'returns config.json when "server" is given', ->
            path = @generator.getDestinationPathByName('server')
            expect(path).to.equal normalize __dirname + '/../../loopback/server/config.json'


    describe 'merge', ->

        before ->
            @generator = new ConfigJSONGenerator()

        it 'merges two object, 1st argument is dominant', ->
            dominant =
                common: 'dominant'
                onlyDominant: true

            base =
                common: 'base'
                onlyBase: true

            merged = @generator.merge(dominant, base)
            expect(merged).to.have.property 'common', 'dominant'
            expect(merged).to.have.property 'onlyDominant', true
            expect(merged).to.have.property 'onlyBase', true


        it 'merges sub objects, 1st argument is dominant', ->
            dominant =
                common: 'dominant'
                sub:
                    common: 'dominant'
                    onlySubDominant: true
                    subsub:
                        common: 'dominant'
                        onlySubSubDominant: true

            base =
                common: 'base'
                sub:
                    common: 'base'
                    onlySubBase: true
                    subsub:
                        common: 'base'
                        onlySubSubBase: true

            merged = @generator.merge(dominant, base)
            expect(merged).to.have.property 'common', 'dominant'
            expect(merged).to.have.property 'sub'

            expect(merged.sub).to.have.property 'common', 'dominant'
            expect(merged.sub).to.have.property 'onlySubDominant', true
            expect(merged.sub).to.have.property 'onlySubBase', true
            expect(merged.sub).to.have.property 'subsub'

            expect(merged.sub.subsub).to.have.property 'common', 'dominant'
            expect(merged.sub.subsub).to.have.property 'onlySubSubDominant', true
            expect(merged.sub.subsub).to.have.property 'onlySubSubBase', true


    describe 'loadDefaultConfig', ->

        it 'loads admin', ->
            config = new ConfigJSONGenerator().loadDefaultConfig('admin')
            expect(config).to.be.an 'object'
            expect(config).to.have.property 'accessToken'

        it 'loads datasources', ->
            config = new ConfigJSONGenerator().loadDefaultConfig('datasources')
            expect(config).to.be.an 'object'
            expect(config).to.have.property 'memory'
            expect(config).to.have.property 'db'

        it 'loads middleware', ->
            config = new ConfigJSONGenerator().loadDefaultConfig('middleware')
            expect(config).to.be.an 'object'

        it 'does not load model-config', ->
            config = new ConfigJSONGenerator().loadDefaultConfig('model-config')
            expect(config).not.to.exist

        it 'loads server', ->
            config = new ConfigJSONGenerator().loadDefaultConfig('server')
            expect(config).to.be.an 'object'
            expect(config).to.have.property 'port', 3000

        it 'loads push-credentials', ->
            config = new ConfigJSONGenerator().loadDefaultConfig('push-credentials')
            expect(config).to.be.an 'object'
            expect(config).to.have.property 'gcmServerApiKey'
            expect(config).to.have.property 'apnsCertData'
            expect(config).to.have.property 'apnsKeyData'


    describe 'getMergedConfig', ->

        it 'merges custom and default configs', ->

            customConfigObj =
                admin:
                    accessToken: 'MySecretOne'
                    account:
                        password: 'xxxyyy'
                models: {}
                xxx: 'yyy'

            generator = new ConfigJSONGenerator(customConfigObj)

            merged = generator.getMergedConfig('admin')

            expect(merged).to.have.property 'accessToken', 'MySecretOne'
            expect(merged.account).to.have.property 'email', 'dummy@example.com' # from default config
            expect(merged.account).to.have.property 'password', 'xxxyyy'


    describe 'generate', ->

        before ->
            @tmpdir = __dirname + '/tmp'
            try
                fs.mkdirSync @tmpdir
            catch e

            @generator = new ConfigJSONGenerator(__dirname + '/sample-configs')
            @generator.destinationPath = @tmpdir
            @generatedContents = @generator.generate()

        after ->
            for fname in fs.readdirSync @tmpdir
                fs.unlinkSync @tmpdir + '/' + fname
            fs.rmdirSync @tmpdir

        it 'generates five json files', ->

            expect(fs.readdirSync @tmpdir).to.have.length 5

        it 'generates config.json', ->

            expect(fs.readdirSync @tmpdir).to.include 'config.json'

        it 'returns generated contents', ->

            expect(Object.keys @generatedContents).to.have.length 5


    describe 'reset', ->

        before ->
            @tmpdir = __dirname + '/tmp2'
            try
                fs.mkdirSync @tmpdir
            catch e

            @generator = new ConfigJSONGenerator(__dirname + '/sample-configs')
            @generator.destinationPath = @tmpdir

        after ->
            fs.rmdirSync @tmpdir

        it 'removes all generated files', ->

            @generator.generate()
            expect(fs.readdirSync @tmpdir).to.have.length 5

            @generator.reset()
            expect(fs.readdirSync @tmpdir).to.have.length 0

