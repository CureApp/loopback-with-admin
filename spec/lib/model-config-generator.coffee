
{ normalize } = require 'path'

fs = require 'fs'

ModelConfigGenerator = require '../../src/lib/model-config-generator'


describe 'ModelConfigGenerator', ->


    describe 'getDestinationPathByName', ->

        it 'returns model-config.json', ->
            generator = new ModelConfigGenerator()
            path = generator.getDestinationPathByName('model-config')
            expect(path).to.equal normalize __dirname + '/../../loopback/server/model-config.json'


    describe 'loadDefaultConfig', ->

        it 'loads model-config', ->
            config = new ModelConfigGenerator().loadDefaultConfig('model-config')
            expect(config).to.be.an 'object'
            expect(Object.keys config).to.have.length 10


    describe 'loadCustomConfig', ->

        it 'returns model config for each entity names', ->
            entityNames = [
                'player'
                'instrument'
                'song'
            ]
            config = new ModelConfigGenerator(entityNames).loadCustomConfig()
            expect(Object.keys config).to.have.length 3
            expect(config.player).to.have.property 'dataSource', 'db'
            expect(config.player).to.have.property 'public', true


    describe 'getMergedConfig', ->

        it 'returns model config for each entity names', ->
            entityNames = [
                'player'
                'instrument'
                'song'
            ]
            config = new ModelConfigGenerator(entityNames).getMergedConfig('model-config')
            expect(Object.keys config).to.have.length 10 + 3



