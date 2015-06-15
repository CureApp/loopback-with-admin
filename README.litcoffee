# loopback-with-domain

run loopback server with "domain"

domain is in this context business logic, the same as Domain-Driven Design (DDD).

connection with [base-domain](https://github.com/CureApp/base-domain)

also, this loopback extends original [loopback](https://github.com/strongloop/loopback).

- admin
- push notification

follow these section to see how to use admin and push notification

# install

```bash
npm install loopback-with-domain
```

# simplest run, without domain

you can just run loopback without domain information by

    require('loopback-with-domain').runWithoutDomain().then (lbInfo) ->

        console.log lbInfo.getURL()         # loopback api root
        console.log lbInfo.getAccessToken() # access token of admin

then loopback server (with admin, push-notification function) runs


# run with domain

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


    lbWithDomain = require 'loopback-with-domain'

    configDir = '/path/to/config-dir'

    domain = require('base-domain').createInstance(dirname: 'domain')

    lbWithDomain.runWithDomain(domain, configDir).then ->
        # loopback started

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
 db          | datasource for domain entities

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
name, base, relations and properties are automatically set from domain information.

## aclType
loopback-with-domain generates acls from aclType.

three types are available.

 aclType     | meaning
-------------|-----------------------------------------------------
 admin       | only admin can CRUD the model
 owner       | admin and the owner of the model can CRUD
 public-read | everyone can READ the model and admin can CRUD


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
then, loopback-with-domain selects configs in "local" directory.

## passing custom environment with argument

    env = 'production'

    lbWithDomain.runWithDomain(domain, configDir, env)

env is prior to NODE\_ENV settings.


# modified loopback-datasource-juggler

using [CureApp/loopback-datasource-juggler](https://github.com/CureApp/loopback-datasource-juggler).

this repository is almost the same as original one except 'memory' connector handles id as string
(orignally integer).
