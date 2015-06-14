
ModelDefinition = require '../../src/lib/model-definition'

class EntityModel extends require('base-domain').Entity
    @properties:
        extmodel: @TYPES.MODEL 'extmodel'

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



    describe 'toStringifiedJSON', ->
