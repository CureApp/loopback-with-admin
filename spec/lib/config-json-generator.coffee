
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


    describe 'loadDefaultConfigs', ->

        before ->
            @configs = new ConfigJSONGenerator().loadDefaultConfigs()

        it 'has six configs', ->
            expect(Object.keys @configs).to.have.length 6

        it 'loads admin', ->
            expect(@configs.admin).to.be.an 'object'
            expect(@configs.admin).to.have.property 'accessToken'

        it 'loads datasources', ->
            expect(@configs.datasources).to.be.an 'object'
            expect(@configs.datasources).to.have.property 'memory'
            expect(@configs.datasources).to.have.property 'db'

        it 'loads middleware', ->
            expect(@configs.middleware).to.be.an 'object'

        it 'loads model-config', ->
            expect(@configs['model-config']).to.be.an 'object'

        it 'loads server', ->
            expect(@configs.server).to.be.an 'object'
            expect(@configs.server).to.have.property 'port', 3000

        it 'loads push-credentials', ->
            expect(@configs['push-credentials']).to.be.an 'object'
            expect(@configs['push-credentials']).to.have.property 'gcmServerApiKey'
            expect(@configs['push-credentials']).to.have.property 'apnsCertData'
            expect(@configs['push-credentials']).to.have.property 'apnsKeyData'


    describe 'getMergedConfigs', ->

        it 'merges custom and default configs', ->

            customConfig =
                admin:
                    accessToken: 'MySecretOne'
                    account:
                        password: 'xxxyyy'
                server:
                    port: 4157

            merged = new ConfigJSONGenerator(customConfig).getMergedConfigs()

            expect(merged.admin).to.have.property 'accessToken', 'MySecretOne'
            expect(merged.server).to.have.property 'port', 4157
            expect(merged.admin.account).to.have.property 'email', 'dummy@example.com' # from default config
            expect(merged.admin.account).to.have.property 'password', 'xxxyyy'


        it 'does not include unnecessary keys', ->

            customConfig =
                xxx:
                    yyy: true

            merged = new ConfigJSONGenerator(customConfig).getMergedConfigs()

            expect(merged).not.to.have.property 'xxx'
            expect(Object.keys merged).to.have.length 6


    describe 'generate', ->

        before ->
            @tmpdir = __dirname + '/tmp'
            try
                fs.mkdirSync @tmpdir
            catch e

            customConfig =
                admin: accessToken: 'MySecretOne'
                server: port: 4157

            @generator = new ConfigJSONGenerator(customConfig)
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
