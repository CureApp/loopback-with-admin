
ModelDefinition = require '../../src/lib/model-definition'


describe 'ModelDefinition', ->

    describe 'constructor', ->

        it 'use custom acls setting if exists', ->
            customDefinition =
                acls: ['xxx']
            def = new ModelDefinition('entity-model', customDefinition)
            assert.deepEqual def.definition.acls, ['xxx']


        it 'set acls by aclType', ->
            customDefinition = aclType: 'owner'
            def = new ModelDefinition('entity-model', customDefinition)
            assert def.definition.acls instanceof Array
            assert def.definition.acls.length > 1


        it 'use custom relations setting', ->
            customDefinition =
                relations: 'xxx'
            def = new ModelDefinition('entity-model', customDefinition)
            assert def.definition.relations is 'xxx'


    describe 'isUser', ->

        it 'returns false by default', ->
            modelDefinition = new ModelDefinition('xxx')
            assert modelDefinition.isUser() is false

        it 'returns true if base is User', ->
            modelDefinition = new ModelDefinition('xxx', base: 'User')
            assert modelDefinition.isUser() is true

        it 'returns true if base is not User', ->
            modelDefinition = new ModelDefinition('xxx', base: 'Users')
            assert modelDefinition.isUser() is false


    describe 'aclType', ->

        it 'is admin by default', ->
            modelDefinition = new ModelDefinition('xxx')
            assert modelDefinition.aclType is 'admin'

        it 'follows customDefinition value', ->
            modelDefinition = new ModelDefinition('xxx', aclType: 'public-read')
            assert modelDefinition.aclType is 'public-read'


        it 'returns "custom" when aclType is not set and acls exist', ->
            modelDefinition = new ModelDefinition('xxx', acls: [])
            assert modelDefinition.aclType is 'custom'


    describe 'toJSON', ->

        before ->
            @def = new ModelDefinition('entity-model', base: 'User')
            @json = @def.toJSON()

        it 'has name', ->
            assert @json.name is 'entity-model'

        it 'has plural', ->
            assert @json.plural is 'entity-model'

        it 'has base = User', ->
            assert @json.base is 'User'

        it 'has idInjection', ->
            assert @json.idInjection is true

        it 'has acls', ->
            assert @json.hasOwnProperty 'acls'
            assert @json.acls instanceof Array

        it 'has relations', ->
            assert @json.hasOwnProperty 'relations'


    describe 'toStringifiedJSON', ->

        it 'returns stringified definition', ->

            def = new ModelDefinition('xxx')
            stringifiedJSON = def.toStringifiedJSON()
            -> JSON.parse(stringifiedJSON)

            parsed = JSON.parse(stringifiedJSON)
            assert.deepEqual parsed, def.toJSON()
