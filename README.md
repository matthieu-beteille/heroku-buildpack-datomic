Heroku buildpack to start a Datomic Transactor
==============================================

## What this buildpack does

- obtains and packages Datomic

- prepares Postgres for use by Datomic (if not done)

- starts the Datomic transactor

The rest of this README explains the necessary configuration.

## Heroku pre-requisites

This technology exploits the features of [Heroku Spaces](https://www.heroku.com/private-spaces) to securely inter-connect dynos. 

To use this buildpack you need to have access to Heroku Spaces. Outside of Heroku Spaces, Datomic security is not assured.

## Configuring a custom buildpack

To enable this buildpack on an existing project:

````heroku buildpacks:set https://github.com/opengrail/heroku-buildpack-datomic -a myapp````

For more options and information see the [Heroku web site on third party buildpacks](https://devcenter.heroku.com/articles/third-party-buildpacks#using-a-custom-buildpack)

## Detection

The buildpack will detect that you wish to start a Datomic transactor if your project has a Procfile in its top level directory that has this line:

````datomic: /app/scripts/start-datomic.sh````

## Configuration

### Datomic free configuration - playtime only!!

By default Datomic free will be started. *Data will not be stored between startups*

You can optionally configure the version of Datomic you wish to deploy (default is `0.9.5327`)

````heroku config:set DATOMIC_VERSION version-number````

### Datomic Pro configuration

You can get a free copy of the [Datomic Pro starter edition](http://www.datomic.com/get-datomic.html) or bring your supported license.

````heroku config:set DATOMIC_LICENSE_PASSWORD license-password````

````heroku config:set DATOMIC_LICENSE_USER license-user````

````heroku config:set DATOMIC_TRANSACTOR_KEY license-key````

You can optionally configure the version of Datomic you wish to deploy (default is `0.9.5327`)

````heroku config:set DATOMIC_VERSION version-number````

### Heroku Addons - Pro editions only

To run any of the Pro editions, this buildpack needs you to have a Postgres database. 

The only Postgres database supported is `Heroku Postgres (free or paid)`

This buildpack will automatically configure Postgres for use with Datomic (if not already done) 

## Dyno size

Transactors require a minimum of 1Gb RAM in all cases. In production, 4Gb or more is preferred.

## Dyno count

To manage failover for the Pro edition (not starter or free), 2 Transactors can be started. 

If the lead transactor fails, the other worker can takeover.

When clients connect to the storage they will be automatically transitioned to the new lead transactor.

## ToDo

- Enable further configuration such as JVM memory 

- Add other storage options that are not available on the Heroku platform

## Basis

This is forked from the official [Heroku buildpack](http://devcenter.heroku.com/articles/buildpack) for Java apps.


License
-------

Licensed under the MIT License. See LICENSE file.
