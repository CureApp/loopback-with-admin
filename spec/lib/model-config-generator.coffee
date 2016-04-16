
{ normalize } = require 'path'

fs = require 'fs-extra'

ModelConfigGenerator = require '../../src/lib/model-config-generator'


describe 'ModelConfigGenerator', ->


    describe 'getDestinationPathByName', ->

        it 'returns model-config.json', ->
            generator = new ModelConfigGenerator()
            path = generator.getDestinationPathByName('model-config')
            assert path is normalize __dirname + '/../../loopback/server/model-config.json'


    describe 'loadDefaultConfig', ->

        it 'loads model-config', ->
            config = new ModelConfigGenerator().loadDefaultConfig('model-config')
            assert typeof config is 'object'
            assert Object.keys(config).length is 10


    describe 'customConfigObj', ->

        it 'contains model config for each entity names', ->
            entityNames = [
                'player'
                'instrument'
                'song'
            ]
            config = new ModelConfigGenerator(entityNames).customConfigObj['model-config']
            assert Object.keys(config).length is 3
            assert config.player.dataSource is 'db'
            assert config.player.public is true


    describe 'getMergedConfig', ->

        it 'returns model config for each entity names', ->
            entityNames = [
                'player'
                'instrument'
                'song'
            ]
            config = new ModelConfigGenerator(entityNames).getMergedConfig('model-config')
            assert Object.keys(config).length is 10 + 3


    describe 'generate', ->

        before ->
            @generator = new ModelConfigGenerator(['e1', 'e2'])
            @generator.destinationPath = __dirname + '/d'
            fs.mkdirsSync __dirname + '/d'

        after ->
            fs.removeSync __dirname + '/d'


        it 'returns model config', ->

            generated = @generator.generate()
            assert Object.keys(generated).length is 10 + 2


