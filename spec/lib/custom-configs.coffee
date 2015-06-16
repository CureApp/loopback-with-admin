
CustomConfigs = require '../../src/lib/custom-configs'

describe 'CustomConfigs', ->

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


    describe 'loadModelDefinitions', ->

        it 'returns custom model-definitions object', ->

            configDir = __dirname + '/music-live-configs'

            definitions = new CustomConfigs().loadModelDefinitions(configDir)

            expect(definitions).to.have.property 'player'
            expect(definitions.player).to.have.property 'base', 'User'

            expect(definitions).to.have.property 'instrument'
            expect(definitions.instrument).to.have.property 'aclType', 'owner'


        it 'returns empty object if configDir is not given', ->

            definitions = new CustomConfigs().loadModelDefinitions()
            expect(definitions).to.eql {}


    describe 'getModelDefinitions', ->

        it 'returns "models" value if constructed with config object', ->

            config =
                models:
                    m1: true

            definitions = new CustomConfigs(config).getModelDefinitions()
            expect(definitions).to.have.property 'm1', true

