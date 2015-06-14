
{ normalize } = require 'path'

LoopbackLauncher = require '../../src/lib/loopback-launcher'
Main = require '../../src/main'

domainDir = normalize __dirname + '/domains/music-live'
domain = require('base-domain').createInstance dirname: domainDir
configDir = normalize __dirname + '/music-live-configs'


describe 'LoopbackLauncher', ->

    before ->
        @main = new Main(domain, configDir)
        @main.reset()
        @main.generate()

    after ->
        @main.reset()


    describe 'launch', ->

        it 'spawns loopback process', (done) ->
            @timeout 30000

            launcher = new LoopbackLauncher()
            launcher.launch().then (lbProcess) ->
                lbProcess.kill()
                done()
            .catch done


    describe 'rejectOnFailure', ->


    describe 'rejectOnTimeout', ->

    describe 'removeListeners', ->

    describe 'resolveOnStarted', ->


