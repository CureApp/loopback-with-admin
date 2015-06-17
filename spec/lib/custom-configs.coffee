
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


