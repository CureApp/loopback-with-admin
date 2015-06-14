
CustomConfigLoader = require '../../src/lib/custom-config-loader'

configDir = __dirname + '/sample-configs'

describe 'CustomConfigLoader', ->

    describe 'load', ->

        it 'loads from environment specific directory', ->

            loader = new CustomConfigLoader(configDir, 'local')

            plainConfig = loader.load('plain')

            expect(plainConfig.key1).to.equal 'from local'

        it 'loads from common directory if environment specific file does not exist', ->

            loader = new CustomConfigLoader(configDir, 'development')

            plainConfig = loader.load('plain')

            expect(plainConfig.key1).to.equal 'from common'

