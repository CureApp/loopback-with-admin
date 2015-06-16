# loopback-with-admin

run loopback server with admin and push notification features.

# install

```bash
npm install loopback-with-admin
```

# simplest run

    require('loopback-with-admin').run().then (lbInfo) ->

        console.log lbInfo.getURL()         # loopback api root
        console.log lbInfo.getAccessToken() # access token of admin


# run with config dir

before running, you can prepare a directory which contains custom config information.

```text
(config-dir) # any name is acceptable
|-- model-definitions.coffee
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

    lbWithAdmin.run(configDir).then ->
        # loopback started

# run with config dir

    lbWithAdmin = require 'loopback-with-admin'

    lbWithAdmin.run(server: port: 3001).then ->


# admin
(coming soon)

# push notification 
(coming soon)


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
-------------|-----------------------
 memory      | on memory datasource
 db          | datasource for custom entities

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


# model definitions

    module.exports =
        player: # model name
            base: 'User'  # the same as loopback model settings.base
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
 admin       | only admin can CRUD the model
 owner       | admin and the owner of the model can CRUD
 public-read | everyone can READ the model and admin can CRUD
 none        | everyone can CRUD the model


# switching environment

running script with environment variable "NODE\_ENV" like

```bash
$ NODE_ENV=production node app.js
```

"development" is selected by default.

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

## passing custom environment with argument

    env = 'production'

    lbWithAdmin.run(configDir, env)

env is prior to NODE\_ENV settings.


# modified loopback-datasource-juggler

using [CureApp/loopback-datasource-juggler](https://github.com/CureApp/loopback-datasource-juggler).

this repository is almost the same as original one except 'memory' connector handles id as string
(orignally integer).
