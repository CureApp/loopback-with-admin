
{ normalize } = require 'path'

fs = require 'fs'

BuildInfoGenerator = require '../../src/lib/build-info-generator'


describe 'ModelConfigGenerator', ->


    describe 'getDestinationPathByName', ->

        it 'returns build-info.json', ->
            generator = new BuildInfoGenerator()
            path = generator.getDestinationPathByName('build-info')
            expect(path).to.equal normalize __dirname + '/../../server/build-info.json'


    describe 'loadDefaultConfig', ->

        it 'loads build-info', ->
            config = new BuildInfoGenerator().loadDefaultConfig('build-info')
            expect(config).to.be.an 'object'


    describe 'loadCustomConfig', ->

        before ->

            domain = require('base-domain').createInstance(dirname: 'dummy-domain-dir')
            configDir = 'dummy-config-dir'
            reset  = true
            env    = 'production'

            @info = new BuildInfoGenerator(domain, configDir, env, reset).loadCustomConfig()

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

        it 'contains reset info', ->
            expect(@info).to.have.property 'reset', true

