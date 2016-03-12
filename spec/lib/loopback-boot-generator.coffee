
fs = require 'fs'

LoopbackBootGenerator = require '../../src/lib/loopback-boot-generator'

describe 'LoopbackBootGenerator', ->

    describe 'generate', ->

        it 'copies javascript files of existing custom role function to loopback/server/custom-roles', ->

            params =
                customRoles:
                    foo: __dirname + '/../custom-roles/abc.js'

            bootGenerator = new LoopbackBootGenerator(params)

            bootGenerator.generate()

            assert fs.existsSync(__dirname + '/../../loopback/server/custom-roles/foo.js') is true


        it 'does not copy non-existing javascript files', ->

            params =
                customRoles:
                    bar: __dirname + '/../custom-roles/xxx.js'

            bootGenerator = new LoopbackBootGenerator(params)

            bootGenerator.generate()

            assert fs.existsSync(__dirname + '/../../loopback/server/custom-roles/bar.js') is false


    describe 'reset', ->

        it 'removes javascript files in loopback/server/custom-roles', ->

            assert fs.existsSync(__dirname + '/../../loopback/server/custom-roles/foo.js') is true

            bootGenerator = new LoopbackBootGenerator()
            bootGenerator.reset()

            assert fs.existsSync(__dirname + '/../../loopback/server/custom-roles/foo.js') is false


