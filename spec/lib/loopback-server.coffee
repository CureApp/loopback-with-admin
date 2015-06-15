
{ normalize } = require 'path'

LoopbackServer = require '../../src/lib/loopback-server'
Main = require '../../src/main'

domainDir = normalize __dirname + '/domains/music-live'
domain = require('base-domain').createInstance dirname: domainDir
configDir = normalize __dirname + '/music-live-configs'


describe 'LoopbackServer', ->

    before ->
        @main = new Main(domain, configDir)
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
