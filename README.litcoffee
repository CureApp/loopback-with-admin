# loopback-with-admin

run loopback server with admin and push notification features.

# install

```bash
npm install loopback-with-admin
```

# usage
## simplest run

    # model definitions
    # see "models" section for more detail
    models =
        'user':
            base: 'User'


    require('loopback-with-admin').run(models).then (lbInfo) ->

        # see "LoopbackInfo" section for more detail
        console.log lbInfo.getURL()         # loopback api root
        console.log lbInfo.getAccessToken() # access token of admin


## run with config dir

before running, you can prepare a directory which contains custom config information.

```text
(config-dir) # any name is acceptable
|-- common
|   |-- server.coffee
|   `-- admin.coffee
|-- development
|   `-- datasources.coffee
`-- production
    `-- datasources.coffee
```

    lbWithAdmin = require 'loopback-with-admin'

    configDir = '/path/to/config-dir'

    lbWithAdmin.run(models, configDir).then ->
        # loopback started

## run with config

    lbWithAdmin = require 'loopback-with-admin'

    lbWithAdmin.run(models, server: port: 3001).then ->

## passing custom environment with argument

    env = 'production'

    require('loopback-with-admin').run(models, configDir, env)

env is defined as

```coffee
    env ?= process.env.NODE_ENV or 'development'
```
- use custom value if passed
- use NODE\_ENV if exists
- default value is 'development'


```bash
$ NODE_ENV=production node app.js
```

when your config dir is

```text
(config-dir) # any name is acceptable
|-- common
|   |-- server.coffee
|   `-- admin.coffee
|-- development
|   `-- datasources.coffee
|-- local
|   `-- datasources.coffee
|-- production
|   `-- datasources.coffee
```

and launching script like

```bash
$ NODE_ENV=local node app.js
```
then, loopback-with-admin selects configs in "local" directory.



# model definitions

    models =
        player: # model name
            base: 'User'  
            aclType: 'admin' # specific for this system

        instrument:
            aclType: 'owner-read'


the same format as [loopback model definition](http://docs.strongloop.com/display/public/LB/Customizing+models)
except "aclType" value.
name is automatically set from definition information.
plural is set to the same value as name if not set manually.

## aclType
loopback-with-admin generates acls from aclType.

three types are available.

 aclType     | meaning
-------------|-----------------------------------------------------
 admin       | only admin can CRUD the model (_default_)
 owner       | admin and the owner of the model can CRUD
 public-read | everyone can READ the model and admin can CRUD
 none        | everyone can CRUD the model


# configs

these are the config names.

- admin
- datasources
- middleware
- server
- push-credentials

see JSON files in "default-values/non-model-configs" directory.
you can set the same properties as these JSONs.


## admin

 config key  | meaning
-------------|-----------------------
 accessToken | accessToken for admin

## datasources

 config key  | meaning
-------------|---------------------------------
 memory      | on memory datasource
 db          | datasource for custom entities

Each datasource name has its connectors.

### available loopback connectors

available datasources are 
- mongodb
- memory
- memory-idstr

"memory-idstr" is the default connector, which stores data only in memory,
and id type is string whereas id type of "memory" is number.



## server

 config key  | meaning       | default
-------------|---------------|----------------
 restApiRoot | REST api root | /api
 port        | port number   | 3000


## push-credentials

 config key      | meaning
-----------------|-------------------------------------------
 gcmServerApiKey | api key for Google Cloud Messaging (GCM)
 apnsCertData    | certificate pem contents for APNs
 apnsKeyData     | key pem contents for APNs

# LoopbackInfo
    require('loopback-with-admin').run().then (lbInfo) ->
        lbInfo instanceof LoopbackInfo # true

instance of LoopbackInfo is obtained after loopback is launched

## getURL()
returns hosting URL

    lbInfo.getURL() # e.g. localhost:3000/api

## getEnv()
returns environment name where loopback launched

    lbInfo.getEnv() # development|production or other custom environments

## getAccessToken()
returns access token of admin

    lbInfo.getAccessToken()

## config
contains all config values used to build loopback.

- admin
- datasources
- middleware
- server
- push-credentials

see configs section above.

## models
contains model definitions used to build loopback

see models section above.


# admin
(coming soon)

# push notification 
(coming soon)



