
AclConditions = require '../../src/lib/acl-conditions'

describe 'AclConditions', ->

    describe 'hasCustomWrite', ->

        it '「my-customのrw」はカスタム権限の編集許可を持っている', ->

            aclType =
                'owner': 'rwx'
                'my-custom': 'rw'

            aclConditions = new AclConditions(aclType)
            assert aclConditions.hasCustomWrite() is true

        it '「my-customのr」はカスタム権限の編集許可を持っていない', ->

            aclType =
                'owner': 'rwx'
                'my-custom': 'r'

            aclConditions = new AclConditions(aclType)
            assert aclConditions.hasCustomWrite() is false

        it '「owner」はカスタム権限の編集許可を持っていない', ->

            aclType = 'owner'

            aclConditions = new AclConditions(aclType)
            assert aclConditions.hasCustomWrite() is false

        it '「public」はカスタム権限の編集許可を持っていない', ->

            aclType = 'public'

            aclConditions = new AclConditions(aclType)
            assert aclConditions.hasCustomWrite() is false

        it '「admin」はカスタム権限の編集許可を持っていない', ->

            aclType = 'admin'

            aclConditions = new AclConditions(aclType)
            assert aclConditions.hasCustomWrite() is false

        it '「member」はカスタム権限の編集許可を持っていない', ->

            aclType = 'member'

            aclConditions = new AclConditions(aclType)
            assert aclConditions.hasCustomWrite() is false