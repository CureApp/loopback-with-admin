
AclGenerator = require '../../src/lib/acl-generator'

describe 'AclGenerator', ->

    userModelSetting =
        isUserModel: -> true

    nonUserModelSetting =
        isUserModel: -> false

    commonACL = new AclGenerator(nonUserModelSetting).commonACL().acl

    describe 'userACL', ->

        before ->
            @aclGenerator = new AclGenerator()
            @aclGenerator.userACL()

        it 'appends two ACs', ->
            expect(@aclGenerator.acl).to.have.length 2

        it 'appends AC denying logout by admin', ->
            ac = @aclGenerator.acl[0]
            expect(ac).to.have.property 'principalType', 'ROLE'
            expect(ac).to.have.property 'principalId', 'admin'
            expect(ac).to.have.property 'permission', 'DENY'
            expect(ac).to.have.property 'property', 'logout'

        it 'appends AC denying creation by everyone', ->
            ac = @aclGenerator.acl[1]
            expect(ac).to.have.property 'principalType', 'ROLE'
            expect(ac).to.have.property 'principalId', '$everyone'
            expect(ac).to.have.property 'permission', 'DENY'
            expect(ac).to.have.property 'property', 'create'


    describe 'commonACL', ->

        describe 'with non-user model', ->

            before ->
                @aclGenerator = new AclGenerator(nonUserModelSetting)
                @aclGenerator.commonACL()

            it 'appends two ACs', ->
                expect(@aclGenerator.acl).to.have.length 2

            it 'appends AC denying everyone\'s access in the first place', ->
                ac = @aclGenerator.acl[0]

                expect(ac).to.have.property 'principalType', 'ROLE'
                expect(ac).to.have.property 'principalId', '$everyone'
                expect(ac).to.have.property 'permission', 'DENY'

            it 'appends AC allowing admin\'s access', ->
                ac = @aclGenerator.acl[1]

                expect(ac).to.have.property 'principalType', 'ROLE'
                expect(ac).to.have.property 'principalId', 'admin'
                expect(ac).to.have.property 'permission', 'ALLOW'


        describe 'with user model', ->

            it 'appends four ACs', ->
                aclGenerator = new AclGenerator(userModelSetting)
                aclGenerator.commonACL()
                expect(aclGenerator.acl).to.have.length 4


            it 'userACL() is called after basic ACL are appended', (done) ->
                aclGenerator = new AclGenerator(userModelSetting)

                aclGenerator.userACL = ->
                    expect(aclGenerator.acl).to.have.length 2
                    done()

                aclGenerator.commonACL()


    describe 'adminUserACL', ->
        before ->
            @aclGenerator = new AclGenerator()
            @aclGenerator.adminUserACL()

        it 'appends two ACs', ->
            expect(@aclGenerator.acl).to.have.length 2

        it 'appends AC denying login by everyone', ->
            ac = @aclGenerator.acl[0]
            expect(ac).to.have.property 'principalType', 'ROLE'
            expect(ac).to.have.property 'principalId', '$everyone'
            expect(ac).to.have.property 'permission', 'DENY'
            expect(ac).to.have.property 'property', 'login'

        it 'appends AC denying creation by everyone', ->
            ac = @aclGenerator.acl[1]
            expect(ac).to.have.property 'principalType', 'ROLE'
            expect(ac).to.have.property 'principalId', 'admin'
            expect(ac).to.have.property 'permission', 'ALLOW'
            expect(ac).to.have.property 'property', 'login'


    describe 'adminACL', ->

        describe 'with non-user model', ->

            it 'appends two ACs, the same as commonACL()', ->

                aclGenerator = new AclGenerator(nonUserModelSetting)
                aclGenerator.adminACL()
                expect(aclGenerator.acl).to.have.length 2
                expect(aclGenerator.acl).to.deep.equal commonACL


        describe 'with user model', ->

            it 'appends six ACs', ->
                aclGenerator = new AclGenerator(userModelSetting)
                aclGenerator.adminACL()
                expect(aclGenerator.acl).to.have.length 6


            it 'userACL(), adminUserACL() is called after basic ACL are appended', (done) ->
                aclGenerator = new AclGenerator(userModelSetting)
                userACLCalled = false

                aclGenerator.userACL = ->
                    expect(aclGenerator.acl).to.have.length 2
                    userACLCalled = true

                aclGenerator.adminUserACL = ->
                    expect(aclGenerator.acl).to.have.length 2
                    done() if userACLCalled

                aclGenerator.adminACL()


    describe 'ownerACL', ->
        describe 'with non-user model', ->
            before ->
                @aclGenerator = new AclGenerator(nonUserModelSetting)
                @aclGenerator.ownerACL()

            it 'appends five ACs, the first two are the same as commonACL()', ->
                expect(@aclGenerator.acl).to.have.length 5
                expect(@aclGenerator.acl.slice(0,2)).to.deep.equal commonACL

            it 'appends AC allowing read, write, by admin for owner', ->
                accessTypes = ['READ', 'WRITE', 'EXECUTE']

                for ac in @aclGenerator.acl.slice(2)
                    expect(ac).to.have.property 'principalType', 'ROLE'
                    expect(ac).to.have.property 'principalId', '$owner'
                    expect(ac).to.have.property 'permission', 'ALLOW'
                    expect(accessTypes).to.include ac.accessType


        describe 'with user model', ->
            it 'appends seven ACs', ->
                aclGenerator = new AclGenerator(userModelSetting)
                aclGenerator.ownerACL()
                expect(aclGenerator.acl).to.have.length 7


    describe 'publicReadACL', ->
        describe 'with non-user model', ->
            before ->
                @aclGenerator = new AclGenerator(nonUserModelSetting)
                @aclGenerator.publicReadACL()

            it 'appends three ACs, the first two are the same as commonACL()', ->
                expect(@aclGenerator.acl).to.have.length 3
                expect(@aclGenerator.acl.slice(0,2)).to.deep.equal commonACL

            it 'appends AC allowing everyone to READ', ->

                for ac in @aclGenerator.acl.slice(2)
                    expect(ac).to.have.property 'principalType', 'ROLE'
                    expect(ac).to.have.property 'principalId', '$everyone'
                    expect(ac).to.have.property 'permission', 'ALLOW'
                    expect(ac).to.have.property 'accessType', 'READ'


        describe 'with user model', ->
            it 'appends five ACs', ->
                aclGenerator = new AclGenerator(userModelSetting)
                aclGenerator.publicReadACL()
                expect(aclGenerator.acl).to.have.length 5





    describe 'generateByType', ->
