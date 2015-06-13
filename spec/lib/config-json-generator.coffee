
{ normalize } = require 'path'

fs = require 'fs'

ConfigJSONGenerator = require '../../src/lib/config-json-generator'


describe 'ConfigJSONGenerator', ->


    describe 'getDestinationPathByName', ->

        before ->
            @generator = new ConfigJSONGenerator()

        it 'returns #{configName}.json', ->
            path = @generator.getDestinationPathByName('admin')
            expect(path).to.equal normalize __dirname + '/../../server/admin.json'


        it 'returns config.json when "server" is given', ->
            path = @generator.getDestinationPathByName('server')
            expect(path).to.equal normalize __dirname + '/../../server/config.json'


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

        it 'loads model-config', ->
            config = new ConfigJSONGenerator().loadDefaultConfig('model-config')
            expect(config).to.be.an 'object'

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

            generator = new ConfigJSONGenerator()

            generator.customConfigLoader =
                load: ->
                    accessToken: 'MySecretOne'
                    account:
                        password: 'xxxyyy'


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

        after ->
            for fname in fs.readdirSync @tmpdir
                fs.unlinkSync @tmpdir + '/' + fname
            fs.rmdirSync @tmpdir

        it 'generates six json files', ->

            @generator.generate()
            expect(fs.readdirSync @tmpdir).to.have.length 6

        it 'generates config.json', ->

            configJSONPath = normalize @tmpdir + '/config.json'
            files = @generator.generate()
            expect(files).to.include configJSONPath
