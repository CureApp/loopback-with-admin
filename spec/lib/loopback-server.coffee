
{ normalize } = require 'path'

LoopbackServer = require '../../src/lib/loopback-server'
Main = require '../../src/main'

config = server: port: 3001

describe 'LoopbackServer', ->

    before ->
        @main = new Main({}, config)
        @main.reset()
        @main.generate()

    after ->
        @main.reset()


    describe 'launch', ->

        it 'runs loopback in the same process', ->
            @timeout 30000

            launcher = new LoopbackServer()
            launcher.launch(config.server)
