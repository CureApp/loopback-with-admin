
ModelSetting = require '../../src/lib/model-setting'

class EntityModel extends require('base-domain').Entity
    @properties:
        extmodel: @TYPES.MODEL 'extmodel'

describe 'ModelSetting', ->

    describe 'getName', ->

        it 'returns name of entity', ->
            modelSetting = new ModelSetting(EntityModel)
            expect(modelSetting.getName()).to.equal 'entity-model'

    describe 'isUser', ->

        it 'returns false by default', ->
            modelSetting = new ModelSetting(EntityModel)
            expect(modelSetting.isUser()).to.be.false

        it 'returns true if base is User', ->
            modelSetting = new ModelSetting(EntityModel, base: 'User')
            expect(modelSetting.isUser()).to.be.true

        it 'returns true if base is not User', ->
            modelSetting = new ModelSetting(EntityModel, base: 'Users')
            expect(modelSetting.isUser()).to.be.false


    describe 'aclType', ->

        it 'is admin by default', ->
            modelSetting = new ModelSetting(EntityModel)
            expect(modelSetting.aclType).to.equal 'admin'

        it 'follows customSetting value', ->
            modelSetting = new ModelSetting(EntityModel, aclType: 'public-read')
            expect(modelSetting.aclType).to.equal 'public-read'



    describe 'getACL', ->

        it 'returns acl by aclType and isUser or not', ->

            adminACL     = new ModelSetting(EntityModel).getACL()
            adminACL2    = new ModelSetting(EntityModel, aclType: 'admin').getACL()
            adminUserACL = new ModelSetting(EntityModel, base: 'User').getACL()
            ownerUserACL = new ModelSetting(EntityModel, base: 'User', aclType: 'owner').getACL()

            expect(adminACL).to.eql adminACL2
            expect(adminUserACL).not.to.eql adminACL
            expect(adminUserACL).not.to.eql ownerUserACL
            expect(adminACL).not.to.eql ownerUserACL


    describe 'getRelations', ->



    describe 'toStringifiedJSON', ->
