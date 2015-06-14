
ModelDefinition = require '../../src/lib/model-definition'

Domain = require('base-domain')

domain = Domain.createInstance()

class EntityModel extends Domain.Entity
    @properties:
        em: @TYPES.MODEL 'ext-model'

class ExtModel extends Domain.Entity

EntityModel = domain.addClass('entity-model', EntityModel)
ExtModel    = domain.addClass('ext-model', ExtModel)

describe 'ModelDefinition', ->

    describe 'getName', ->

        it 'returns name of entity', ->
            modelDefinition = new ModelDefinition(EntityModel)
            expect(modelDefinition.getName()).to.equal 'entity-model'

    describe 'isUser', ->

        it 'returns false by default', ->
            modelDefinition = new ModelDefinition(EntityModel)
            expect(modelDefinition.isUser()).to.be.false

        it 'returns true if base is User', ->
            modelDefinition = new ModelDefinition(EntityModel, base: 'User')
            expect(modelDefinition.isUser()).to.be.true

        it 'returns true if base is not User', ->
            modelDefinition = new ModelDefinition(EntityModel, base: 'Users')
            expect(modelDefinition.isUser()).to.be.false


    describe 'aclType', ->

        it 'is admin by default', ->
            modelDefinition = new ModelDefinition(EntityModel)
            expect(modelDefinition.aclType).to.equal 'admin'

        it 'follows customDefinition value', ->
            modelDefinition = new ModelDefinition(EntityModel, aclType: 'public-read')
            expect(modelDefinition.aclType).to.equal 'public-read'



    describe 'getACL', ->

        it 'returns acl by aclType and isUser or not', ->

            adminACL     = new ModelDefinition(EntityModel).getACL()
            adminACL2    = new ModelDefinition(EntityModel, aclType: 'admin').getACL()
            adminUserACL = new ModelDefinition(EntityModel, base: 'User').getACL()
            ownerUserACL = new ModelDefinition(EntityModel, base: 'User', aclType: 'owner').getACL()

            expect(adminACL).to.eql adminACL2
            expect(adminUserACL).not.to.eql adminACL
            expect(adminUserACL).not.to.eql ownerUserACL
            expect(adminACL).not.to.eql ownerUserACL


    describe 'getRelations', ->
        it 'returns relations by EntityModel\'s property', ->

            rels = new ModelDefinition(EntityModel).getRelations()

            expect(rels).to.have.property 'em'
            expect(rels.em).to.have.property 'type', 'belongsTo'
            expect(rels.em).to.have.property 'model', 'ext-model'
            expect(rels.em).to.have.property 'foreignKey', 'extModelId'


    describe 'toJSON', ->

        before ->
            @def = new ModelDefinition(EntityModel, base: 'User')
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
            expect(@json.acls).to.eql @def.getACL()

        it 'has relations', ->
            expect(@json).to.have.property 'relations'
            expect(@json.relations).to.eql @def.getRelations()


    describe 'toStringifiedJSON', ->

        it 'returns stringified definition', ->

            def = new ModelDefinition(EntityModel)
            stringifiedJSON = def.toStringifiedJSON()
            expect(-> JSON.parse(stringifiedJSON)).not.to.throw Error

            parsed = JSON.parse(stringifiedJSON)
            expect(parsed).to.eql def.toJSON()
