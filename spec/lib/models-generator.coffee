
{ normalize } = require 'path'
{ mkdirSyncRecursive, rmdirSyncRecursive }  = require 'wrench'
fs = require 'fs'

ModelsGenerator      = require '../../src/lib/models-generator'
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
            assert mGenerator.modelConfigGenerator instanceof ModelConfigGenerator


    describe 'createModelDefinitions', ->

        it 'creates models included in customDefinitions', ->

            customDefinitions = a: {}
            defs = new ModelsGenerator().createModelDefinitions(customDefinitions)
            assert defs.hasOwnProperty 'a'
            assert not defs.hasOwnProperty 'b'


    describe 'modelConfigGenerator', ->

        it 'has model config with models included in customDefinitions', ->

            customDefinitions = a: {}
            mcGenerator = new ModelsGenerator(customDefinitions).modelConfigGenerator
            mergedConfig = mcGenerator.getMergedConfig('model-config')
            assert mergedConfig.hasOwnProperty 'a'
            assert not mergedConfig.hasOwnProperty 'b'



    describe 'getEmptyJSContent', ->

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
            assert fs.existsSync(@generator.destinationDir + '/test-model.json') is true
            assert.deepEqual require(@generator.destinationDir + '/test-model.json'), {test: true}

        it 'generate JS file', ->
            assert fs.existsSync(@generator.destinationDir + '/test-model.json') is true
            content = fs.readFileSync(@generator.destinationDir + '/test-model.js', 'utf8')
            assert content is @generator.getEmptyJSContent()


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
            assert fs.readdirSync(@generator.destinationDir).length is 8


        it 'generate JS file', ->
            assert fs.readdirSync(@generator.destinationDir).length is 8


    describe 'generateDefinitionFiles', ->

    describe 'reset', ->

        before ->
            @generator = new ModelsGenerator()
            @generator.destinationDir = __dirname + '/c'
            @generator.modelConfigGenerator.destinationPath = __dirname + '/c'
            mkdirSyncRecursive __dirname + '/c'


        it 'remove dir if exists', ->
            @generator.reset()
            assert fs.existsSync(@generator.destinationDir) is false

        it 'do nothing if dir does not exist', ->
            => @generator.reset()


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

            assert generated.hasOwnProperty 'config'
            assert generated.hasOwnProperty 'names'
            assert generated.names instanceof Array
            assert generated.names.length is 4
            assert typeof generated.config is 'object'



