
{ normalize } = require 'path'
{ mkdirSyncRecursive, rmdirSyncRecursive }  = require 'wrench'

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


    describe 'customConfigObj', ->

        it 'contains model config for each entity names', ->
            entityNames = [
                'player'
                'instrument'
                'song'
            ]
            config = new ModelConfigGenerator(entityNames).customConfigObj['model-config']
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


    describe 'generate', ->

        before ->
            @generator = new ModelConfigGenerator(['e1', 'e2'])
            @generator.destinationPath = __dirname + '/d'
            mkdirSyncRecursive __dirname + '/d'

        after ->
            rmdirSyncRecursive __dirname + '/d'


        it 'returns model config', ->

            generated = @generator.generate()
            expect(Object.keys generated).to.have.length 10 + 2


