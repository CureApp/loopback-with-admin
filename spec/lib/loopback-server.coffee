
{ normalize } = require 'path'
{ get } = require 'http'
assert = require 'power-assert'

LoopbackServer = require '../../src/lib/loopback-server'
Main = require '../../src/main'

config = server: port: 3001

describe 'LoopbackServer', ->

    before ->
        @main = new Main({}, {})
        @main.reset()
        @main.generate()

    after ->
        @main.reset()


    describe 'launch', ->

        it 'runs loopback at localhost:3000, if call launch() without argument', ->
            @timeout 30000

            launcher = new LoopbackServer()
            launcher.launch()
            .then () ->
                get 'http://localhost:3000', (res) ->　assert res.status is 200

        it 'runs loopback at localhost:3001, if argument is passed to launch()', ->
            @timeout 30000

            launcher = new LoopbackServer()
            launcher.launch(config.server)
            .then () ->
                get 'http://localhost:3001', (res) ->　assert res.status is 200

        it 'runs loopback at localhost:4444, if there is no argument but PORT is set', ->
            @timeout 30000

            process.env.PORT = 4444
            launcher = new LoopbackServer()
            launcher.launch()
            .then () ->
                get 'http://localhost:4444', (res) ->　assert res.status is 200
