
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
            assert @info.hasOwnProperty 'modelDefinitions'
            assert @info.modelDefinitions.player.base is 'User'

        it 'contains custom configs', ->
            assert @info.hasOwnProperty 'customConfigs'

        it 'contains buildAt', ->
            assert @info.hasOwnProperty 'buildAt'
            buildAt = @info.buildAt
            time = new Date(buildAt)
            assert new Date() - time < 1000

        it 'contains env info', ->
            assert @info.env is 'production'


    describe 'getDestinationPathByName', ->

        it 'returns build-info.json', ->
            generator = new BuildInfoGenerator()
            path = generator.getDestinationPathByName('build-info')
            assert path is normalize __dirname + '/../../loopback/server/build-info.json'


    describe 'loadDefaultConfig', ->

        it 'loads build-info', ->
            config = new BuildInfoGenerator().loadDefaultConfig('build-info')
            assert typeof config is 'object'

    describe 'generate', ->

        before ->
            @generator = new BuildInfoGenerator({}, {}, 'development')
            @generator.destinationPath = __dirname + '/d'
            mkdirSyncRecursive __dirname + '/d'

        after ->
            rmdirSyncRecursive __dirname + '/d'


        it 'returns build info', ->

            generated = @generator.generate()
            assert generated.env is 'development'
            assert generated.hasOwnProperty 'buildAt'
            assert generated.hasOwnProperty 'modelDefinitions'
            assert generated.hasOwnProperty 'customConfigs'


