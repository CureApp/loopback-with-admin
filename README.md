# loopback-with-admin

Run loopback server easier.

# features
- passing model definitions via arguments (no need to generate JSON files)
- switching environment easier
- admin role, which can access to all endpoints
- easier ACL settings
- easier custom role settings
- easier push notification settings


# install

```bash
npm install loopback-with-admin
```

# usage
## simplest run

```javascript
// model definitions
// see "models" section for more detail
const models = {
  user: {
    base: 'User'
  }
};

require('loopback-with-admin').run(models).then(lbInfo => {
  // see "LoopbackInfo" section for more detail
  console.log(lbInfo.getURL())         // loopback api root
  console.log(lbInfo.getAdminTokens()) // access tokens of admin
})
```

Or more strictly, pass `models` like

```javascript
require('loopback-with-admin').run({models: models})
```


## run with config dir

before running, you can prepare a directory which contains custom config information.

```text
(config-dir) # any name is acceptable
|-- common
|   |-- server.coffee
|-- development
|   `-- datasources.coffee
`-- production
    `-- datasources.coffee
```

```javascript
const lbWithAdmin = require('loopback-with-admin')
const configDir = '/path/to/config-dir'

lbWithAdmin.run({models: models}, configDir).then(lbInfo => {
  // loopback started with the config
})


```
See "configs" section for more details.


## run with config object

```javascript

const lbWithAdmin = require('loopback-with-admin')
const config = {server: {port: 3001}}
lbWithAdmin.run({models: models}, config)
```

## switching environment

```javascript

const configDir = '/path/to/config-dir'

require('loopback-with-admin').run({models: models}, configDir, {env: 'production'})
```
env is set following the rules.

- uses the passed value if exists
- uses NODE_ENV if exists
- default value is 'development'


When your config dir is

```text
(config-dir) # any name is acceptable
|-- common
|   |-- server.coffee
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

```javascript
const models = {
  player: { // model name
    base: 'User', // following loopback model definition
    aclType: 'admin' // only 'aclType' is the specific property for loopback-with-admin
  },

  instrument: { // another model
    aclType: 'owner-read'
  }
}

require('loopback-with-admin').run({models: models})
```

- Models should be the same format as [loopback model definition](http://docs.strongloop.com/display/public/LB/Customizing+models) except `aclType` value.
- `name` is automatically set from definition information.
- `plural` is set to **the same value as the name** unless you set manually.


## aclType for easier ACL settings
`aclType` is prepared for defining complicated acls easier.
loopback-with-admin generates acls from aclType with the following rules.

 aclType              | meaning
----------------------|-----------------------------------------------------
 admin                | only admin can CRUD the model (_default_)
 owner                | the owner of the model can CRUD
 public-read          | everyone can READ the model and admin can CRUD
 member-read          | authenticated users can READ the model and admin can CRUD
 public-read-by-owner | CRUD by the owner, and read by everyone
 member-read-by-owner | CRUD by the owner, and read by authenticated users
 none                 | everyone can CRUD the model

### more detailed settings

```javascript
const models = {
  player: {
    base: 'User',
    aclType: {
      owner: 'rwx',
      member: 'r'
    }
  }
}
```

aclType can be an object, whose key contains the following roles.

- owner: `$owner` role in LoopBack
- member: `$authenticated` role in LoopBack
- public: `$everyone` role in LoopBack
- [custom roles] : see `custom roles` section.

The values of the keys are `rwx`, which is the same as Unix permission.
`x` here means `EXECUTE` accessType in LoopBack.


See loopback roles for instructions.
https://docs.strongloop.com/display/public/LB/Defining+and+using+roles

### custom roles
You can define custom roles like the following code.

```javascript
const customRoles = {
  'doctor': '/path/to/doctor-role.js',
  'patient': '/path/to/patient-role.js'
}

require('loopback-with-admin').run({models: models, customRoles: customRoles})
```

#### role-defining JS file

In the file, you must export a function, which will be passed to the 2nd argument of `Role.registerResolver` in LoopBack.

See how to define custom roles in LoopBack.
https://docs.strongloop.com/display/public/LB/Defining+and+using+roles

Example:

```javascript

module.exports = function(role, context, cb) {
  var app = this // `app` can be acquired via `this`

  function reject(err) {
    if (err) { return cb(err) }
    cb(null, false)
  }

  if (context.modelName !== 'patient') { return reject() }

  var userId = context.accessToken.userId
  if (!userId || userId === context.modelId) {
      return reject()
  }

  cb(null, true) // is in role
```


# admin role
**`admin` role is the role with which every REST APIs are available**.
The role and one user with it are automatically generated at boot phase.

## admin access tokens
To be `admin`, you need to know its access tokens. The following code can get those.

```javascript
require('loopback-with-admin').run(models, config).then(lbInfo => {
  let tokens = lbInfo.getAdminTokens()
  console.log(tokens) // access tokens (String[]) of admin.
})
```

## set `fetch` function to set tokens
By default, the token is fixed and it's `loopback-with-admin-token`.
**You must change the value by passing `fetch` function**.

```javascript
const admin = {
  fetch: function() {
    return ['your-secret-token1', 'your-secret-token2']
  }
}

require('loopback-with-admin').run(models, config, { admin: admin })
```

## change tokens periodically

```javascript
const admin = {
  fetch: function() {
    return generateSecretValuesByRandom().then(value => [ value ]) // fetch function allows Promise to return
  },
  intervalHours: 24 // change the value every day (by default, it's 12 hours)
}

require('loopback-with-admin').run(models, config, { admin: admin })
```


## admin user information
 property    |  value
-------------|--------------------------------
 id          | loopback-with-admin-user-id
 email       | loopback-with-admin@example.com
 password    | admin-user-password

In fact, these value makes no sense as `admin` can **never be accessed via REST APIs**. No one can login with the account information.



# configs

Four types of configs are available.

- datasources
- middleware
- server
- push-credentials

See JSON files in [default-values/non-model-configs directory](https://github.com/CureApp/loopback-with-admin/tree/master/default-values/non-model-configs).

You can set the same properties as these JSONs.


## datasources

 config key  | meaning
-------------|---------------------------------
 memory      | on memory datasource
 db          | datasource for custom entities

Each datasource name has its connectors.

### available loopback connectors

Available datasources are 
- mongodb
- memory
- memory-idstr

`memory-idstr` is the default connector, which stores data only in memory,
and id type is string whereas id type of "memory" is number.
See [loopback-connector-memory-idstr](https://github.com/CureApp/loopback-connector-memory-idstr).

To use mongodb, add dependencies in package.json of your repository

- loopback-connector-mongodb: "1.13.0"
- mongodb: "2.0.35"


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

`require('loopback-with-admin').run()` returns promise of `LoopbackInfo`.

It contains the information of the launched loopback.

- getURL()
- getAdminTokens()
- config
- models 

## getURL()
Returns hosting URL.

```javascript
const config = {
  server: {
    port: 4156,
    restApiRoot: 'awesome-endpoint'
  }
}
require('loopback-with-admin').run(models, config).then(lbInfo => {
  lbInfo.getURL() // localhost:4156/awesome-endpoint
})
```


## getAdminTokens()
Returns Array of access tokens (string).

```javascript
const admin = {
  fetch: function() {
    return ['your-secret-token1', 'your-secret-token2']
  }
}

require('loopback-with-admin').run(models, config, { admin: admin }).then(lbInfo => {
  console.log(lbInfo.getAdminTokens()) // ['your-secret-token1', 'your-secret-token2']
})
```


## getEnv()
Returns environment name where loopback launched.


## config
Contains all config values used to build loopback.

- datasources
- middleware
- server
- push-credentials

See configs section above.

## models
Contains model definitions used to build loopback

See models section above.

# push notification settings
(coming soon)
