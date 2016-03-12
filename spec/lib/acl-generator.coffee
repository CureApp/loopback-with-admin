
AclGenerator = require '../../src/lib/acl-generator'

describe 'AclGenerator', ->

    commonACL = new AclGenerator().commonACL().acl

    describe 'userACL', ->

        before ->
            @aclGenerator = new AclGenerator()
            @aclGenerator.userACL()

        it 'appends three ACs', ->
            expect(@aclGenerator.acl).to.have.length 3

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

        it 'appends AC allowing creation by admin', ->
            ac = @aclGenerator.acl[2]
            expect(ac).to.have.property 'principalType', 'ROLE'
            expect(ac).to.have.property 'principalId', 'admin'
            expect(ac).to.have.property 'permission', 'ALLOW'
            expect(ac).to.have.property 'property', 'create'


    describe 'commonACL', ->

        describe 'with non-user model', ->

            before ->
                @aclGenerator = new AclGenerator()
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

            it 'appends five ACs', ->
                aclGenerator = new AclGenerator(null, true)
                aclGenerator.commonACL()
                expect(aclGenerator.acl).to.have.length 5


            it 'userACL() is called after basic ACL are appended', (done) ->
                aclGenerator = new AclGenerator(null, true)

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




    describe 'generate', ->

        it 'appends no ACL when aclType is "none"', ->

            aclGenerator = new AclGenerator('none', false)
            expect(aclGenerator.acl).to.eql []

        it 'appends no ACL when aclType is "none" even if it is user model', ->

            aclGenerator = new AclGenerator('none', true)
            expect(aclGenerator.acl).to.eql []


        describe 'when aclType is "admin",', ->

            it 'appends two ACs, the same as commonACL() with nonUser model', ->

                aclType = 'admin'
                isUser = false
                acl = new AclGenerator(aclType, isUser).generate()

                expect(acl).to.have.length 2
                expect(acl).to.deep.equal commonACL


            it 'appends seven ACs with user model', ->

                aclType = 'admin'
                isUser = true
                acl = new AclGenerator(aclType, isUser).generate()

                expect(acl).to.have.length 7


        describe 'when aclType is "owner",', ->


            it 'appends five ACs, the first two are the same as commonACL() with nonUser model', ->
                aclType = 'owner'
                isUser = false
                acl = new AclGenerator(aclType, isUser).generate()

                expect(acl).to.have.length 5
                expect(acl.slice(0,2)).to.deep.equal commonACL


            it 'appends AC allowing read, write, by admin for owner with nonUser', ->

                aclType = 'owner'
                isUser = false
                acl = new AclGenerator(aclType, isUser).generate()

                accessTypes = ['READ', 'WRITE', 'EXECUTE']

                for ac in acl.slice(2)
                    expect(ac).to.have.property 'principalType', 'ROLE'
                    expect(ac).to.have.property 'principalId', '$owner'
                    expect(ac).to.have.property 'permission', 'ALLOW'
                    expect(accessTypes).to.include ac.accessType

            it 'appends eight ACs with user model', ->
                aclType = 'owner'
                isUser = true
                acl = new AclGenerator(aclType, isUser).generate()

                expect(acl).to.have.length 8


        describe 'when aclType is "public-read",', ->

            it 'appends three ACs, the first two are the same as commonACL() with nonUser model', ->

                aclType = 'public-read'
                isUser = false
                acl = new AclGenerator(aclType, isUser).generate()

                expect(acl).to.have.length 3
                expect(acl.slice(0,2)).to.deep.equal commonACL

            it 'appends AC allowing everyone to READ with nonUser model', ->

                aclType = 'public-read'
                isUser = false
                acl = new AclGenerator(aclType, isUser).generate()

                for ac in acl.slice(2)
                    expect(ac).to.have.property 'principalType', 'ROLE'
                    expect(ac).to.have.property 'principalId', '$everyone'
                    expect(ac).to.have.property 'permission', 'ALLOW'
                    expect(ac).to.have.property 'accessType', 'READ'

            it 'appends ACs with user model', ->

                aclType = 'public-read'
                isUser = true
                acl = new AclGenerator(aclType, isUser).generate()

                expect(acl).to.have.length 6


        describe 'when aclType is "member-read",', ->

            it 'appends three ACs, the first two are the same as commonACL() with nonUser model', ->

                aclType = 'member-read'
                isUser = false
                acl = new AclGenerator(aclType, isUser).generate()

                expect(acl).to.have.length 3
                expect(acl.slice(0,2)).to.deep.equal commonACL

            it 'appends AC allowing authenticated users to READ with nonUser model', ->

                aclType = 'member-read'
                isUser = false
                acl = new AclGenerator(aclType, isUser).generate()

                for ac in acl.slice(2)
                    expect(ac).to.have.property 'principalType', 'ROLE'
                    expect(ac).to.have.property 'principalId', '$authenticated'
                    expect(ac).to.have.property 'permission', 'ALLOW'
                    expect(ac).to.have.property 'accessType', 'READ'

            it 'appends ACs with user model', ->

                aclType = 'member-read'
                isUser = true
                acl = new AclGenerator(aclType, isUser).generate()

                expect(acl).to.have.length 6



        describe 'when aclType is "member-read-by-owner",', ->

            it 'appends five ACs, the first two are the same as commonACL() with nonUser model', ->

                aclType = 'member-read-by-owner'
                isUser = false
                acl = new AclGenerator(aclType, isUser).generate()

                expect(acl).to.have.length 5
                expect(acl.slice(0,2)).to.deep.equal commonACL

            it 'appends AC allowing read for member,  write and execute for owner', ->

                aclType = 'member-read-by-owner'
                isUser = false
                acl = new AclGenerator(aclType, isUser).generate()

                acl2 = acl[2]
                expect(acl2).to.have.property 'principalType', 'ROLE'
                expect(acl2).to.have.property 'principalId',   '$authenticated'
                expect(acl2).to.have.property 'permission',    'ALLOW'


                accessTypes = ['WRITE', 'EXECUTE']

                for ac in acl.slice(3, 4)
                    expect(ac).to.have.property 'principalType', 'ROLE'
                    expect(ac).to.have.property 'principalId', '$owner'
                    expect(ac).to.have.property 'permission', 'ALLOW'
                    expect(accessTypes).to.include ac.accessType


            it 'appends ACs with user model', ->

                aclType = 'member-read-by-owner'
                isUser = true
                acl = new AclGenerator(aclType, isUser).generate()

                expect(acl).to.have.length 8


        describe 'when aclType is "public-read-by-owner",', ->


            it 'appends five ACs, the first two are the same as commonACL() with nonUser model', ->

                aclType = 'public-read-by-owner'
                isUser = false
                acl = new AclGenerator(aclType, isUser).generate()

                expect(acl).to.have.length 5
                expect(acl.slice(0, 2)).to.deep.equal commonACL


            it 'appends AC allowing read, write, by admin for owner with nonUser', ->

                aclType = 'public-read-by-owner'
                isUser = false
                acl = new AclGenerator(aclType, isUser).generate()

                accessTypes = ['WRITE', 'EXECUTE']

                acl2 = acl[2]
                expect(acl2).to.have.property 'principalType', 'ROLE'
                expect(acl2).to.have.property 'principalId',   '$everyone'
                expect(acl2).to.have.property 'permission',    'ALLOW'


                for ac in acl.slice(3, 4)
                    expect(ac).to.have.property 'principalType', 'ROLE'
                    expect(ac).to.have.property 'principalId', '$owner'
                    expect(ac).to.have.property 'permission', 'ALLOW'
                    expect(accessTypes).to.include ac.accessType


            it 'appends ACs with user model', ->

                aclType = 'public-read-by-owner'
                isUser = true
                acl = new AclGenerator(aclType, isUser).generate()

                expect(acl).to.have.length 8



