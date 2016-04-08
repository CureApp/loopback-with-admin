
AclGenerator = require '../../src/lib/acl-generator'

describe 'AclGenerator', ->

    commonACL = new AclGenerator().commonACL().acl

    describe 'userACL', ->

        before ->
            @aclGenerator = new AclGenerator()
            @aclGenerator.userACL()

        it 'appends three ACs', ->
            assert @aclGenerator.acl.length is 3

        it 'appends AC denying logout by admin', ->
            ac = @aclGenerator.acl[0]
            assert ac.principalType is 'ROLE'
            assert ac.principalId is 'admin'
            assert ac.permission is 'DENY'
            assert ac.property is 'logout'

        it 'appends AC denying creation by everyone', ->
            ac = @aclGenerator.acl[1]
            assert ac.principalType is 'ROLE'
            assert ac.principalId is '$everyone'
            assert ac.permission is 'DENY'
            assert ac.property is 'create'

        it 'appends AC allowing creation by admin', ->
            ac = @aclGenerator.acl[2]
            assert ac.principalType is 'ROLE'
            assert ac.principalId is 'admin'
            assert ac.permission is 'ALLOW'
            assert ac.property is 'create'


    describe 'commonACL', ->

        describe 'with non-user model', ->

            before ->
                @aclGenerator = new AclGenerator()
                @aclGenerator.commonACL()

            it 'appends two ACs', ->
                assert @aclGenerator.acl.length is 2

            it 'appends AC denying everyone\'s access in the first place', ->
                ac = @aclGenerator.acl[0]

                assert ac.principalType is 'ROLE'
                assert ac.principalId is '$everyone'
                assert ac.permission is 'DENY'

            it 'appends AC allowing admin\'s access', ->
                ac = @aclGenerator.acl[1]

                assert ac.principalType is 'ROLE'
                assert ac.principalId is 'admin'
                assert ac.permission is 'ALLOW'


        describe 'with user model', ->

            it 'appends five ACs', ->
                aclGenerator = new AclGenerator(null, true)
                aclGenerator.commonACL()
                assert aclGenerator.acl.length is 5


            it 'userACL() is called after basic ACL are appended', (done) ->
                aclGenerator = new AclGenerator(null, true)

                aclGenerator.userACL = ->
                    assert aclGenerator.acl.length is 2
                    done()

                aclGenerator.commonACL()


    describe 'adminUserACL', ->
        before ->
            @aclGenerator = new AclGenerator()
            @aclGenerator.adminUserACL()

        it 'appends two ACs', ->
            assert @aclGenerator.acl.length is 2

        it 'appends AC denying login by everyone', ->
            ac = @aclGenerator.acl[0]
            assert ac.principalType is 'ROLE'
            assert ac.principalId is '$everyone'
            assert ac.permission is 'DENY'
            assert ac.property is 'login'

        it 'appends AC denying creation by everyone', ->
            ac = @aclGenerator.acl[1]
            assert ac.principalType is 'ROLE'
            assert ac.principalId is 'admin'
            assert ac.permission is 'ALLOW'
            assert ac.property is 'login'




    describe 'generate', ->

        it 'appends no ACL when aclType is "none"', ->

            aclGenerator = new AclGenerator('none', false)
            assert.deepEqual aclGenerator.acl, []

        it 'appends no ACL when aclType is "none" even if it is user model', ->

            aclGenerator = new AclGenerator('none', true)
            assert.deepEqual aclGenerator.acl, []


        describe 'when aclType is "admin",', ->

            it 'appends two ACs, the same as commonACL() with nonUser model', ->

                aclType = 'admin'
                isUser = false
                acl = new AclGenerator(aclType, isUser).generate()

                assert acl.length is 2
                assert.deepEqual acl, commonACL


            it 'appends seven ACs with user model', ->

                aclType = 'admin'
                isUser = true
                acl = new AclGenerator(aclType, isUser).generate()

                assert acl.length is 7


        describe 'when aclType is "owner",', ->


            it 'appends five ACs, the first two are the same as commonACL() with nonUser model', ->
                aclType = 'owner'
                isUser = false
                acl = new AclGenerator(aclType, isUser).generate()

                assert acl.length is 5
                assert.deepEqual acl.slice(0,2), commonACL


            it 'appends AC allowing read, write, by admin for owner with nonUser', ->

                aclType = 'owner'
                isUser = false
                acl = new AclGenerator(aclType, isUser).generate()

                accessTypes = ['READ', 'WRITE', 'EXECUTE']

                for ac in acl.slice(2)
                    assert ac.principalType is 'ROLE'
                    assert ac.principalId is '$owner'
                    assert ac.permission is 'ALLOW'
                    assert ac.accessType in accessTypes

            it 'appends eight ACs with user model', ->
                aclType = 'owner'
                isUser = true
                acl = new AclGenerator(aclType, isUser).generate()

                assert acl.length is 8


        describe 'when aclType is "public-read",', ->

            it 'appends three ACs, the first two are the same as commonACL() with nonUser model', ->

                aclType = 'public-read'
                isUser = false
                acl = new AclGenerator(aclType, isUser).generate()

                assert acl.length is 3
                assert.deepEqual acl.slice(0,2), commonACL

            it 'appends AC allowing everyone to READ with nonUser model', ->

                aclType = 'public-read'
                isUser = false
                acl = new AclGenerator(aclType, isUser).generate()

                for ac in acl.slice(2)
                    assert ac.principalType is 'ROLE'
                    assert ac.principalId is '$everyone'
                    assert ac.permission is 'ALLOW'
                    assert ac.accessType is 'READ'

            it 'appends ACs with user model', ->

                aclType = 'public-read'
                isUser = true
                acl = new AclGenerator(aclType, isUser).generate()

                assert acl.length is 6


        describe 'when aclType is "member-read",', ->

            it 'appends three ACs, the first two are the same as commonACL() with nonUser model', ->

                aclType = 'member-read'
                isUser = false
                acl = new AclGenerator(aclType, isUser).generate()

                assert acl.length is 3
                assert.deepEqual acl.slice(0,2), commonACL

            it 'appends AC allowing authenticated users to READ with nonUser model', ->

                aclType = 'member-read'
                isUser = false
                acl = new AclGenerator(aclType, isUser).generate()

                for ac in acl.slice(2)
                    assert ac.principalType is 'ROLE'
                    assert ac.principalId is '$authenticated'
                    assert ac.permission is 'ALLOW'
                    assert ac.accessType is 'READ'

            it 'appends ACs with user model', ->

                aclType = 'member-read'
                isUser = true
                acl = new AclGenerator(aclType, isUser).generate()

                assert acl.length is 6



        describe 'when aclType is "member-read-by-owner",', ->

            it 'appends five ACs, the first two are the same as commonACL() with nonUser model', ->

                aclType = 'member-read-by-owner'
                isUser = false
                acl = new AclGenerator(aclType, isUser).generate()

                assert acl.length is 5
                assert.deepEqual acl.slice(0,2), commonACL

            it 'appends AC allowing read for member,  write and execute for owner', ->

                aclType = 'member-read-by-owner'
                isUser = false
                acl = new AclGenerator(aclType, isUser).generate()

                acl2 = acl[2]
                assert acl2.principalType is 'ROLE'
                assert acl2.principalId is '$authenticated'
                assert acl2.permission is 'ALLOW'


                accessTypes = ['WRITE', 'EXECUTE']

                for ac in acl.slice(3, 4)
                    assert ac.principalType is 'ROLE'
                    assert ac.principalId is '$owner'
                    assert ac.permission is 'ALLOW'
                    assert ac.accessType in accessTypes


            it 'appends ACs with user model', ->

                aclType = 'member-read-by-owner'
                isUser = true
                acl = new AclGenerator(aclType, isUser).generate()

                assert acl.length is 8


        describe 'when aclType is "public-read-by-owner",', ->


            it 'appends five ACs, the first two are the same as commonACL() with nonUser model', ->

                aclType = 'public-read-by-owner'
                isUser = false
                acl = new AclGenerator(aclType, isUser).generate()

                assert acl.length is 5
                assert.deepEqual acl.slice(0, 2), commonACL


            it 'appends AC allowing read, write, by admin for owner with nonUser', ->

                aclType = 'public-read-by-owner'
                isUser = false
                acl = new AclGenerator(aclType, isUser).generate()

                accessTypes = ['WRITE', 'EXECUTE']

                acl2 = acl[2]
                assert acl2.principalType is 'ROLE'
                assert acl2.principalId is '$everyone'
                assert acl2.permission is 'ALLOW'


                for ac in acl.slice(3, 4)
                    assert ac.principalType is 'ROLE'
                    assert ac.principalId is '$owner'
                    assert ac.permission is 'ALLOW'
                    assert ac.accessType in accessTypes


            it 'appends ACs with user model', ->

                aclType = 'public-read-by-owner'
                isUser = true
                acl = new AclGenerator(aclType, isUser).generate()

                assert acl.length is 8



