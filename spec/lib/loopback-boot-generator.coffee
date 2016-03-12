
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

            expect(fs.existsSync(__dirname + '/../../loopback/server/custom-roles/foo.js')).to.be.true


        it 'does not copy non-existing javascript files', ->

            params =
                customRoles:
                    bar: __dirname + '/../custom-roles/xxx.js'

            bootGenerator = new LoopbackBootGenerator(params)

            bootGenerator.generate()

            expect(fs.existsSync(__dirname + '/../../loopback/server/custom-roles/bar.js')).to.be.false


    describe 'reset', ->

        it 'removes javascript files in loopback/server/custom-roles', ->

            expect(fs.existsSync(__dirname + '/../../loopback/server/custom-roles/foo.js')).to.be.true

            bootGenerator = new LoopbackBootGenerator()
            bootGenerator.reset()

            expect(fs.existsSync(__dirname + '/../../loopback/server/custom-roles/foo.js')).to.be.false


