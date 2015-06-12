
{ normalize } = require 'path'

ModelsGenerator = require '../src/models-generator'


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
            expect(path).to.equal normalize __dirname + '/../common/models/password-change-ticket.json'

    describe 'getEntityModelsFromDomain', ->

    describe 'createModelSetting', ->

    describe 'generate', ->
