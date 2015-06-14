
{ normalize } = require 'path'

fs = require 'fs'

ModelConfigGenerator = require '../../src/lib/model-config-generator'


describe 'ModelConfigGenerator', ->


    describe 'getDestinationPathByName', ->

        it 'returns model-config.json', ->
            generator = new ModelConfigGenerator()
            path = generator.getDestinationPathByName('model-config')
            expect(path).to.equal normalize __dirname + '/../../server/model-config.json'


    describe 'loadDefaultConfig', ->

        it 'loads model-config', ->
            config = new ModelConfigGenerator().loadDefaultConfig('model-config')
            expect(config).to.be.an 'object'


    xdescribe 'loadCustomConfig', ->

    xdescribe 'generate', ->
