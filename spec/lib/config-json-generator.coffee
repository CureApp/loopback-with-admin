
{ normalize } = require 'path'

fs = require 'fs'

ConfigJSONGenerator = require '../../src/lib/config-json-generator'


describe 'ConfigJSONGenerator', ->


    describe 'getDestinationPathByName', ->

        before ->
            @generator = new ConfigJSONGenerator()

        it 'returns #{configName}.json', ->
            path = @generator.getDestinationPathByName('admin')
            assert path is normalize __dirname + '/../../loopback/server/admin.json'


        it 'returns config.json when "server" is given', ->
            path = @generator.getDestinationPathByName('server')
            assert path is normalize __dirname + '/../../loopback/server/config.json'


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
            assert merged.common is 'dominant'
            assert merged.onlyDominant is true
            assert merged.onlyBase is true


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
            assert merged.common is 'dominant'
            assert merged.hasOwnProperty 'sub'

            assert merged.sub.common is 'dominant'
            assert merged.sub.onlySubDominant is true
            assert merged.sub.onlySubBase is true
            assert merged.sub.hasOwnProperty 'subsub'

            assert merged.sub.subsub.common is 'dominant'
            assert merged.sub.subsub.onlySubSubDominant is true
            assert merged.sub.subsub.onlySubSubBase is true


    describe 'loadDefaultConfig', ->

        it 'loads admin', ->
            config = new ConfigJSONGenerator().loadDefaultConfig('admin')
            assert typeof config is 'object'
            assert config.hasOwnProperty 'accessToken'

        it 'loads datasources', ->
            config = new ConfigJSONGenerator().loadDefaultConfig('datasources')
            assert typeof config is 'object'
            assert config.hasOwnProperty 'memory'
            assert config.hasOwnProperty 'db'

        it 'loads middleware', ->
            config = new ConfigJSONGenerator().loadDefaultConfig('middleware')
            assert typeof config is 'object'

        it 'does not load model-config', ->
            config = new ConfigJSONGenerator().loadDefaultConfig('model-config')
            assert not config?

        it 'loads server', ->
            config = new ConfigJSONGenerator().loadDefaultConfig('server')
            assert typeof config is 'object'
            assert config.port is 3000

        it 'loads push-credentials', ->
            config = new ConfigJSONGenerator().loadDefaultConfig('push-credentials')
            assert typeof config is 'object'
            assert config.hasOwnProperty 'gcmServerApiKey'
            assert config.hasOwnProperty 'apnsCertData'
            assert config.hasOwnProperty 'apnsKeyData'


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

            assert merged.accessToken is 'MySecretOne'
            assert merged.account.email is 'dummy@example.com' # from default config
            assert merged.account.password is 'xxxyyy'


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

            assert fs.readdirSync(@tmpdir).length is 5

        it 'generates config.json', ->

            assert 'config.json' in fs.readdirSync @tmpdir

        it 'returns generated contents', ->

            assert Object.keys @generatedContents.length is 5


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
            assert fs.readdirSync(@tmpdir).length is 5

            @generator.reset()
            assert fs.readdirSync(@tmpdir).length is 0

