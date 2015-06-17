
{ normalize } = require 'path'
{ mkdirSyncRecursive, rmdirSyncRecursive }  = require 'wrench'
fs = require 'fs'

ModelsGenerator      = require '../../src/lib/models-generator'
EmptyModelDefinition = require '../../src/lib/empty-model-definition'
ModelDefinition      = require '../../src/lib/model-definition'
ModelConfigGenerator = require '../../src/lib/model-config-generator'

describe 'ModelsGenerator', ->

    describe 'constructor', ->
        before ->
            { @createModelDefinitions } = ModelsGenerator::
            ModelsGenerator::createModelDefinitions = ->
                model1: true
                model2: true

        after ->
            ModelsGenerator::createModelDefinitions = @createModelDefinitions

        it 'generate ModelConfigGenerator with array of models', ->
            mGenerator = new ModelsGenerator()
            expect(mGenerator.modelConfigGenerator).to.be.instanceof ModelConfigGenerator


    xdescribe 'createDefinition', ->

        it 'returns ModelDefinition with EntityModel when domain and model exists', ->

            domain = BaseDomain.createInstance()
            domain.addClass('a', class A extends BaseDomain.Entity)

            customDefinition = {}

            def = new ModelsGenerator().createDefinition(customDefinition, 'a', domain)
            expect(def).to.have.property 'Entity', domain.getModel 'a'


        it 'returns EmptyModelDefinition when model is not Entity', ->

            domain = BaseDomain.createInstance()
            domain.addClass('a', class A extends BaseDomain.BaseModel)

            customDefinition = {}

            def = new ModelsGenerator().createDefinition(customDefinition, 'a', domain)
            expect(def).to.be.instanceof EmptyModelDefinition
            expect(def.getName()).to.equal 'a'

        it 'returns EmptyModelDefinition when model does not exist', ->

            domain = BaseDomain.createInstance()
            customDefinition = {}

            def = new ModelsGenerator().createDefinition(customDefinition, 'a', domain)
            expect(def).to.be.instanceof EmptyModelDefinition
            expect(def.getName()).to.equal 'a'


        it 'returns EmptyModelDefinition when domain does not exist', ->
            customDefinition = {}

            def = new ModelsGenerator().createDefinition(customDefinition, 'a')
            expect(def).to.be.instanceof EmptyModelDefinition
            expect(def.getName()).to.equal 'a'


    xdescribe 'createModelDefinitions', ->

        it 'creates models only included in customDefinitions', ->
            domain = BaseDomain.createInstance()
            domain.addClass('a', class A extends BaseDomain.Entity)
            domain.addClass('b', class B extends BaseDomain.Entity)

            customDefinitions = a: {}
            defs = new ModelsGenerator().createModelDefinitions(customDefinitions, domain)
            expect(defs).to.have.property 'a'
            expect(defs).not.to.have.property 'b'


    xdescribe 'modelConfigGenerator', ->

        it 'has model config with models included in customDefinitions', ->
            domain = BaseDomain.createInstance()
            domain.addClass('a', class A extends BaseDomain.Entity)
            domain.addClass('b', class B extends BaseDomain.Entity)

            customDefinitions = a: {}
            mcGenerator = new ModelsGenerator(customDefinitions, domain).modelConfigGenerator
            mergedConfig = mcGenerator.getMergedConfig('model-config')
            expect(mergedConfig).to.have.property 'a'
            expect(mergedConfig).not.to.have.property 'b'



    xdescribe 'getEmptyJSContent', ->

        it 'returns valid JS code', ->

            vm = require 'vm'

            mGenerator = new ModelsGenerator()
            context = vm.createContext module: {}

            vm.runInContext(mGenerator.getEmptyJSContent(), context)



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


    describe 'generateDefinitionFiles', ->

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



