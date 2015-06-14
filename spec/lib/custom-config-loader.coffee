
CustomConfigLoader = require '../../src/lib/custom-config-loader'

configDir = __dirname + '/sample-configs'

describe 'CustomConfigLoader', ->

    describe 'env', ->

        it 'is "development" by default', ->

            loader = new CustomConfigLoader(configDir)
            expect(loader.env).to.equal 'development'


        it 'is set the same as environment variable "NODE_ENV" if set.', ->

            process.env.NODE_ENV = 'xxxx'
            loader = new CustomConfigLoader(configDir)

            expect(loader.env).to.equal 'xxxx'

            process.env.NODE_ENV = ''


        it 'is set value from constructor if set.', ->
            process.env.NODE_ENV = 'xxxx'
            loader = new CustomConfigLoader(configDir, 'local')

            expect(loader.env).to.equal 'local'
            process.env.NODE_ENV = ''


    describe 'load', ->

        it 'loads from environment specific directory', ->

            loader = new CustomConfigLoader(configDir, 'local')

            plainConfig = loader.load('plain')

            expect(plainConfig.key1).to.equal 'from local'

        it 'loads from common directory if environment specific file does not exist', ->

            loader = new CustomConfigLoader(configDir, 'development')

            plainConfig = loader.load('plain')

            expect(plainConfig.key1).to.equal 'from common'

