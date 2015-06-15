
{ normalize } = require 'path'
{ mkdirSyncRecursive, rmdirSyncRecursive }  = require 'wrench'

fs = require 'fs'

BuildInfoGenerator = require '../../src/lib/build-info-generator'


describe 'BuildInfoGenerator', ->


    describe 'getDestinationPathByName', ->

        it 'returns build-info.json', ->
            generator = new BuildInfoGenerator()
            path = generator.getDestinationPathByName('build-info')
            expect(path).to.equal normalize __dirname + '/../../loopback/server/build-info.json'


    describe 'loadDefaultConfig', ->

        it 'loads build-info', ->
            config = new BuildInfoGenerator().loadDefaultConfig('build-info')
            expect(config).to.be.an 'object'


    describe 'loadCustomConfig', ->

        before ->

            domain = require('base-domain').createInstance(dirname: 'dummy-domain-dir')
            configDir = 'dummy-config-dir'
            env    = 'production'

            @info = new BuildInfoGenerator(domain, configDir, env).loadCustomConfig()

        it 'contains domain info', ->
            expect(@info).to.have.property 'domainType', 'Facade'
            expect(@info).to.have.property 'domainDir', 'dummy-domain-dir'

        it 'contains configDir', ->
            expect(@info).to.have.property 'configDir', 'dummy-config-dir'

        it 'contains buildAt', ->
            expect(@info).to.have.property 'buildAt'
            buildAt = @info.buildAt
            time = new Date(buildAt)
            expect(new Date() - time).to.be.lessThan 1000

        it 'contains env info', ->
            expect(@info).to.have.property 'env', 'production'


    describe 'generate', ->

        before ->
            domain = dirname: 'dummy'
            configDir = 'dummy2'
            @generator = new BuildInfoGenerator(domain, configDir, 'development')
            @generator.destinationPath = __dirname + '/d'
            mkdirSyncRecursive __dirname + '/d'

        after ->
            rmdirSyncRecursive __dirname + '/d'


        it 'returns build info', ->

            generated = @generator.generate()
            expect(generated).to.have.property 'env', 'development'
            expect(generated).to.have.property 'buildAt'
            expect(generated).to.have.property 'domainType'
            expect(generated).to.have.property 'domainDir', 'dummy'
            expect(generated).to.have.property 'configDir', 'dummy2'


