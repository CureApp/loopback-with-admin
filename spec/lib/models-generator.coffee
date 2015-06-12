
{ normalize } = require 'path'

ModelsGenerator = require '../../src/lib/models-generator'


describe 'ModelsGenerator', ->
    describe 'getEmptyJSContent', ->

        it 'returns valid JS code', ->

            vm = require 'vm'

            mGenerator = new ModelsGenerator()
            context = vm.createContext module: {}

            vm.runInContext(mGenerator.getEmptyJSContent(), context)

    describe 'getDestinationPath', ->

        it 'returns destination path by model name and extension info', ->

            mGenerator = new ModelsGenerator()
            path = mGenerator.getDestinationPath('password-change-ticket', 'json')
            expect(path).to.equal normalize __dirname + '/../../common/models/password-change-ticket.json'


    describe 'getEntityModelsFromDomain', ->

        it 'returns empty array if no entities found', ->

            domainDir = normalize __dirname + '/domains/no-entities'
            domain = require('base-domain').createInstance dirname: domainDir

            mGenerator = new ModelsGenerator()

            entityModels = mGenerator.getEntityModelsFromDomain(domain)


        it 'returns entities from domain directory', ->

            domainDir = normalize __dirname + '/domains/music-live'
            domain = require('base-domain').createInstance dirname: domainDir

            mGenerator = new ModelsGenerator()


            entityModels = mGenerator.getEntityModelsFromDomain(domain)
            expect(entityModels).to.have.length.above 2

            entityNames = [
                'song'
                'player'
                'instrument'
            ].sort()

            names = (e.getName() for e in entityModels).sort()
            expect(names).to.eql entityNames

            for entityModel in entityModels
                expect(entityModel).to.have.property 'isEntity', true


    describe 'createModelSetting', ->

    describe 'generate', ->
