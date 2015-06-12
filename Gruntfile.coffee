
module.exports = (grunt) ->

    grunt.config.init

        'mocha-chai-sinon':
            spec:
                src: [
                    'spec/*.coffee'
                ]
                options:
                    ui: 'bdd'
                    reporter: 'spec'
                    require: 'coffee-script/register'

            single:
                src: [
                    grunt.option('file') ? 'spec/config-json-generator.coffee'
                ]
                options:
                    ui: 'bdd'
                    reporter: 'spec'
                    require: 'coffee-script/register'

    grunt.loadNpmTasks 'grunt-mocha-chai-sinon'
    grunt.loadNpmTasks 'grunt-contrib-coffee'

    grunt.registerTask 'default', 'mocha-chai-sinon:spec'
    grunt.registerTask 'single', 'mocha-chai-sinon:single'
