____ = require('debug')('loopback-with-admin:participant-token-setter')

PARTICIPANT_USER =
    email: 'loopback-with-participant@example.com'
    id: 'loopback-with-admin-participant'
    password: 'participant-user-password' # No worry, noone can login through REST API.

HUNDRED_YEARS = 60 * 60 * 24 * 365 * 100

DEFAULT_TOKEN = 'loopback-with-admin-participant'

promisify = (fn) ->
    new Promise (y, n) =>
        cb = (e, o) => if e? then n(e) else y(o)
        fn(cb)


###*
Participant token setter

@class ParticipantTokenSetter
###
class ParticipantTokenSetter

    ###*
    @param {String} token participant token
    ###
    constructor: (@token = DEFAULT_TOKEN) ->


    set: (@models) ->

        @createUser()
        .then =>
            @createRole()
        .then =>
            @setToken(@token)

    ###*
    Create participant user
    @private
    ###
    createUser: ->
        ____("creating participant user. id: #{PARTICIPANT_USER.id}")
        { User } = @models

        promisify (cb) =>
            User.create PARTICIPANT_USER, cb


    ###*
    Create participant role
    @private
    ###
    createRole: ->

        ____("creating participant role.")
        { Role, RoleMapping } = @models

        promisify (cb) =>
            Role.create name: 'participant', cb

        .then (role) =>
            principal =
                principalType: RoleMapping.USER
                principalId: PARTICIPANT_USER.id

            promisify (cb) =>
                role.principals.create principal, cb


    ###*
    set new token
    @private
    ###
    setToken: (token) ->

        { AccessToken } = @models

        @findById(token).then (foundToken) =>

            if foundToken?
                ____("token: #{token} already exists.")

                if foundToken.userId isnt PARTICIPANT_USER.id
                    console.error """
                        ParticipantTokenSetter: The token `#{token}` is already exist for non-participant user. Skip creating.
                    """
                    console.error()

                return false

            ____("saving token: #{token}")
            promisify (cb) =>
                AccessToken.create { id: token, userId: PARTICIPANT_USER.id, ttl: HUNDRED_YEARS }, cb

            .then => true


    ###*
    Find AccessToken model by tokenStr
    @private
    ###
    findById: (tokenStr) ->

        { AccessToken } = @models

        promisify (cb) =>
            AccessToken.findById tokenStr, cb


module.exports = ParticipantTokenSetter
