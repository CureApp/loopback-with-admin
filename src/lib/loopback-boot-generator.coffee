
{ normalize } = require 'path'
fs = require 'fs'

class LoopbackBootGenerator

    @dirpath: normalize __dirname + '/../../loopback/server/custom-roles'


    constructor: (params = {}) ->

        { @customRoles } = params

    generate: ->

        return null if not @customRoles

        for name, filepath of @customRoles
            if not fs.existsSync(filepath)
                delete @customRoles[name]
            else
                fs.writeFileSync(@constructor.dirpath + '/' + name + '.js', fs.readFileSync(filepath))

        return customRoles: @customRoles


    reset: ->
        for filename in fs.readdirSync(@constructor.dirpath) when filename.slice(-3) is '.js'
            fs.unlinkSync(@constructor.dirpath + '/' + filename)


module.exports = LoopbackBootGenerator
