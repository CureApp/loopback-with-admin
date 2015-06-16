
{ normalize } = require 'path'

LoopbackServer = require '../../src/lib/loopback-server'
Main = require '../../src/main'

domainDir = normalize __dirname + '/domains/music-live'
domain = require('base-domain').createInstance dirname: domainDir


describe 'LoopbackServer', ->

    before ->
        @main = new Main(domain, server: port: 3001)
        @main.reset()
        @main.generate()

    after ->
        @main.reset()


    describe 'launch', ->

        it 'runs loopback in the same process', (done) ->
            @timeout 30000

            launcher = new LoopbackServer()
            launcher.launch().then (app) ->
                done()
            .catch done
