
CustomConfigs = require '../../src/lib/custom-configs'

describe 'CustomConfigs', ->

    describe 'loadEnvDir', ->

        it 'loads env dir if exists', ->
            configDir = __dirname + '/music-live-configs'
            configs = new CustomConfigs().loadEnvDir(configDir, 'development')
            assert configs.hasOwnProperty 'server'
            assert not configs.hasOwnProperty 'plain'

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

            assert configs.hasOwnProperty 'plain'
            assert configs.server.port is 8080


   describe 'toObject,', ->

        describe 'when instance is create from config object', ->
            it 'contains copy of the given object', ->
                configObj = {abc: true}
                customConfigs = new CustomConfigs(configObj)
                assert customConfigs.toObject().abc is true

        describe 'when instance is create from config object', ->
            it 'contains config in the directory', ->

                configDir = __dirname + '/music-live-configs'
                customConfigs = new CustomConfigs(configDir)
                assert customConfigs.toObject().hasOwnProperty 'plain'



