
{ normalize } = require 'path'
{ mkdirSyncRecursive, rmdirSyncRecursive }  = require 'wrench'

fs = require 'fs'

BuildInfoGenerator = require '../../src/lib/build-info-generator'


describe 'BuildInfoGenerator', ->


    describe 'getMergedConfig', ->

        before ->

            modelDefinitions = player: 'base': 'User'
            configObj = server: port: 3001
            env    = 'production'

            @info = new BuildInfoGenerator(modelDefinitions, configObj, env).getMergedConfig()

        it 'contains modelDefinitions', ->
            expect(@info).to.have.property 'modelDefinitions'
            expect(@info.modelDefinitions.player.base).to.equal 'User'

        it 'contains custom configs', ->
            expect(@info).to.have.property 'customConfigs'

        it 'contains buildAt', ->
            expect(@info).to.have.property 'buildAt'
            buildAt = @info.buildAt
            time = new Date(buildAt)
            expect(new Date() - time).to.be.lessThan 1000

        it 'contains env info', ->
            expect(@info).to.have.property 'env', 'production'


    describe 'getDestinationPathByName', ->

        it 'returns build-info.json', ->
            generator = new BuildInfoGenerator()
            path = generator.getDestinationPathByName('build-info')
            expect(path).to.equal normalize __dirname + '/../../loopback/server/build-info.json'


    describe 'loadDefaultConfig', ->

        it 'loads build-info', ->
            config = new BuildInfoGenerator().loadDefaultConfig('build-info')
            expect(config).to.be.an 'object'

    describe 'generate', ->

        before ->
            @generator = new BuildInfoGenerator({}, {}, 'development')
            @generator.destinationPath = __dirname + '/d'
            mkdirSyncRecursive __dirname + '/d'

        after ->
            rmdirSyncRecursive __dirname + '/d'


        it 'returns build info', ->

            generated = @generator.generate()
            expect(generated).to.have.property 'env', 'development'
            expect(generated).to.have.property 'buildAt'
            expect(generated).to.have.property 'modelDefinitions'
            expect(generated).to.have.property 'customConfigs'


