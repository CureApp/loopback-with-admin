
{ normalize } = require 'path'

LoopbackProcessLauncher = require '../../src/lib/loopback-process-launcher'
Main = require '../../src/main'

domainDir = normalize __dirname + '/domains/music-live'
domain = require('base-domain').createInstance dirname: domainDir


describe 'LoopbackProcessLauncher', ->

    before ->
        customConfigs =
            server: port: 3002

        @main = new Main(domain, customConfigs)
        @main.reset()
        @main.generate()

    after ->
        @main.reset()


    describe 'launch', ->

        it 'spawns loopback process', (done) ->
            @timeout 30000

            launcher = new LoopbackProcessLauncher()
            launcher.launch().then (lbProcess) ->
                lbProcess.kill()
                done()
            .catch done


    describe 'rejectOnFailure', ->


    describe 'rejectOnTimeout', ->

    describe 'removeListeners', ->

    describe 'resolveOnStarted', ->


