# loopback-with-domain

run loopback server with "domain"

domain is in this context business logic, the same as Domain-Driven Design (DDD).

connection with [base-domain](https://github.com/CureApp/base-domain)


# install

```
npm install loopback-with-domain
```


# run

before running, you can prepare a directory which contains custom config information.


```
(config-dir) # any name is acceptable
|-- common
|   |-- server.coffee
|   `-- admin.coffee
|-- development
|   `-- datasources.coffee
|-- production
|   `-- datasources.coffee
```


    lbWithDomain = require 'loopback-with-domain'

    configDir = '/path/to/config-dir'

    domain = require('base-domain').createInstance(dirname: 'domain')

    lbWithDomain.runWithDomain(domain, configDir).then ->
        # loopback started


# configs

these are the config names.

- admin
- datasources
- middleware
- model-config
- server
- push-credentials

see JSON files in "default-configs" directory.
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


