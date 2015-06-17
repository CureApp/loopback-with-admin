
ModelDefinition = require '../../src/lib/model-definition'


describe 'ModelDefinition', ->

    describe 'constructor', ->

        it 'use custom acls setting if exists', ->
            customDefinition =
                acls: ['xxx']
            def = new ModelDefinition('entity-model', customDefinition)
            expect(def.definition.acls).to.eql ['xxx']


        it 'set acls by aclType', ->
            customDefinition = aclType: 'owner'
            def = new ModelDefinition('entity-model', customDefinition)
            expect(def.definition.acls).to.be.instanceof Array
            expect(def.definition.acls).to.have.length.above 1


        it 'use custom relations setting', ->
            customDefinition =
                relations: 'xxx'
            def = new ModelDefinition('entity-model', customDefinition)
            expect(def.definition.relations).to.equal 'xxx'


    describe 'isUser', ->

        it 'returns false by default', ->
            modelDefinition = new ModelDefinition('xxx')
            expect(modelDefinition.isUser()).to.be.false

        it 'returns true if base is User', ->
            modelDefinition = new ModelDefinition('xxx', base: 'User')
            expect(modelDefinition.isUser()).to.be.true

        it 'returns true if base is not User', ->
            modelDefinition = new ModelDefinition('xxx', base: 'Users')
            expect(modelDefinition.isUser()).to.be.false


    describe 'aclType', ->

        it 'is admin by default', ->
            modelDefinition = new ModelDefinition('xxx')
            expect(modelDefinition.aclType).to.equal 'admin'

        it 'follows customDefinition value', ->
            modelDefinition = new ModelDefinition('xxx', aclType: 'public-read')
            expect(modelDefinition.aclType).to.equal 'public-read'


        it 'returns "custom" when aclType is not set and acls exist', ->
            modelDefinition = new ModelDefinition('xxx', acls: [])
            expect(modelDefinition.aclType).to.equal 'custom'


    describe 'toJSON', ->

        before ->
            @def = new ModelDefinition('entity-model', base: 'User')
            @json = @def.toJSON()

        it 'has name', ->
            expect(@json).to.have.property 'name', 'entity-model'

        it 'has plural', ->
            expect(@json).to.have.property 'plural', 'entity-model'

        it 'has base = User', ->
            expect(@json).to.have.property 'base', 'User'

        it 'has idInjection', ->
            expect(@json).to.have.property 'idInjection', true

        it 'has acls', ->
            expect(@json).to.have.property 'acls'
            expect(@json.acls).to.be.instanceof Array

        it 'has relations', ->
            expect(@json).to.have.property 'relations'


    describe 'toStringifiedJSON', ->

        it 'returns stringified definition', ->

            def = new ModelDefinition('xxx')
            stringifiedJSON = def.toStringifiedJSON()
            expect(-> JSON.parse(stringifiedJSON)).not.to.throw Error

            parsed = JSON.parse(stringifiedJSON)
            expect(parsed).to.eql def.toJSON()
