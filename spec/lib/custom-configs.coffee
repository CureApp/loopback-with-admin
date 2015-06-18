
CustomConfigs = require '../../src/lib/custom-configs'

describe 'CustomConfigs', ->

    describe 'loadEnvDir', ->

        it 'loads env dir if exists', ->
            configDir = __dirname + '/music-live-configs'
            configs = new CustomConfigs().loadEnvDir(configDir, 'development')
            expect(configs).to.have.property 'server'
            expect(configs).not.to.have.property 'plain'

        it 'returns empty object if not exists', ->
            configDir = __dirname + '/music-live-configs'
            configs = new CustomConfigs().loadEnvDir(configDir, 'xxx')
            expect(configs).to.eql {}


    describe 'appendCommonConfigs', ->

        it 'appends common dir if env config does not have the key', ->
            configDir = __dirname + '/music-live-configs'
            configs =
                server:
                    port: 8080
            new CustomConfigs().appendCommonConfigs(configDir, configs)

            expect(configs).to.have.property 'plain'
            expect(configs.server.port).to.equal 8080


   describe 'toObject,', ->

        describe 'when instance is create from config object', ->
            it 'contains copy of the given object', ->
                configObj = {abc: true}
                customConfigs = new CustomConfigs(configObj)
                expect(customConfigs.toObject()).to.have.property 'abc', true

        describe 'when instance is create from config object', ->
            it 'contains config in the directory', ->

                configDir = __dirname + '/music-live-configs'
                customConfigs = new CustomConfigs(configDir)
                expect(customConfigs.toObject()).to.have.property 'plain'



