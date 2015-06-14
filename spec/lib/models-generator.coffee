
{ normalize } = require 'path'
{ mkdirSyncRecursive, rmdirSyncRecursive }  = require 'wrench'
fs = require 'fs'

ModelsGenerator = require '../../src/lib/models-generator'


describe 'ModelsGenerator', ->

    describe 'getEmptyJSContent', ->

        it 'returns valid JS code', ->

            vm = require 'vm'

            mGenerator = new ModelsGenerator()
            context = vm.createContext module: {}

            vm.runInContext(mGenerator.getEmptyJSContent(), context)


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


    describe 'generateJSONandJS', ->

        before ->
            @generator = new ModelsGenerator()
            @generator.destinationDir = __dirname + '/a/b/c'

            mkdirSyncRecursive @generator.destinationDir

            @modelName = 'test-model'
            @contents = JSON.stringify test: true

            @generator.generateJSONandJS(@modelName, @contents)

        after ->
            rmdirSyncRecursive __dirname + '/a'

        it 'generate JSON file', ->
            expect(fs.existsSync @generator.destinationDir + '/test-model.json').to.be.true
            expect(require @generator.destinationDir + '/test-model.json').to.eql {test: true}

        it 'generate JS file', ->
            expect(fs.existsSync @generator.destinationDir + '/test-model.json').to.be.true
            content = fs.readFileSync(@generator.destinationDir + '/test-model.js', 'utf8')
            expect(content).to.equal @generator.getEmptyJSContent()


    describe 'generateBuiltinModels', ->

        before ->
            @generator = new ModelsGenerator()
            @generator.destinationDir = __dirname + '/b/c/d'

            mkdirSyncRecursive @generator.destinationDir

            @modelName = 'test-model'
            @contents = JSON.stringify test: true

            @generator.generateBuiltinModels(@modelName, @contents)

        after ->
            rmdirSyncRecursive __dirname + '/b'

        it 'generate four JSON files', ->
            expect(fs.readdirSync @generator.destinationDir).to.have.length 8


        it 'generate JS file', ->
            expect(fs.readdirSync @generator.destinationDir).to.have.length 8


    describe 'reset', ->

        before ->
            @generator = new ModelsGenerator()
            @generator.destinationDir = __dirname + '/c'
            mkdirSyncRecursive __dirname + '/c'


        it 'remove dir if exists', ->
            @generator.reset()
            expect(fs.existsSync(@generator.destinationDir)).to.be.false

        it 'do nothing if dir does not exist', ->
            expect(=> @generator.reset()).not.to.throw Error

    describe 'createModelDefinition', ->
    describe 'generate', ->
