
{ normalize } = require 'path'
{ mkdirSyncRecursive, rmdirSyncRecursive }  = require 'wrench'
fs = require 'fs'

ModelsGenerator      = require '../../src/lib/models-generator'
ModelDefinition      = require '../../src/lib/model-definition'
ModelConfigGenerator = require '../../src/lib/model-config-generator'
BaseDomain = require('base-domain')

describe 'ModelsGenerator', ->

    describe 'constructor', ->
        before ->
            { @createModelDefinitionsFromDomain } = ModelsGenerator::
            ModelsGenerator::createModelDefinitionsFromDomain = ->
                model1: true
                model2: true

        after ->
            ModelsGenerator::createModelDefinitionsFromDomain = @createModelDefinitionsFromDomain

        it 'generate ModelConfigGenerator with array of models', ->
            mGenerator = new ModelsGenerator()
            expect(mGenerator.modelConfigGenerator).to.be.instanceof ModelConfigGenerator
            expect(mGenerator.modelConfigGenerator.entityNames).to.eql ['model1', 'model2']


    describe 'getEmptyJSContent', ->

        it 'returns valid JS code', ->

            vm = require 'vm'

            mGenerator = new ModelsGenerator()
            context = vm.createContext module: {}

            vm.runInContext(mGenerator.getEmptyJSContent(), context)


    describe 'setHasManyRelations', ->

        before ->
            @domain = BaseDomain.createInstance()

            class A extends BaseDomain.Entity
                @properties:
                    b: @TYPES.MODEL 'b'

            class B extends BaseDomain.Entity

            @domain.addClass('a', A)
            @domain.addClass('b', B)

        it 'set has many relations to related model-definitions', ->

            mGenerator = new ModelsGenerator()

            defA = new ModelDefinition @domain.getModel 'a'
            defB = new ModelDefinition @domain.getModel 'b'

            mGenerator.setHasManyRelations(a: defA, b: defB)

            expect(defB.toJSON().relations).to.have.property 'a'
            expect(defB.toJSON().relations.a).to.have.property 'type', 'hasMany'



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
            @generator.modelConfigGenerator.destinationPath = __dirname + '/c'
            mkdirSyncRecursive __dirname + '/c'


        it 'remove dir if exists', ->
            @generator.reset()
            expect(fs.existsSync(@generator.destinationDir)).to.be.false

        it 'do nothing if dir does not exist', ->
            expect(=> @generator.reset()).not.to.throw Error


    describe 'generate', ->

        before ->
            @generator = new ModelsGenerator()
            @generator.destinationDir = __dirname + '/d'
            @generator.modelConfigGenerator.destinationPath = __dirname + '/d'
            mkdirSyncRecursive __dirname + '/d'

        after ->
            rmdirSyncRecursive __dirname + '/d'

        it 'returns generated models and configs', ->

            generated = @generator.generate()

            expect(generated).to.have.property 'config'
            expect(generated).to.have.property 'names'
            expect(generated.names).to.be.instanceof Array
            expect(generated.names).to.have.length 4
            expect(generated.config).to.be.an 'object'
