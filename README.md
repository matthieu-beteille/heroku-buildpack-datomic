Heroku buildpack to start Datomic
=================================

This is based on the official [Heroku buildpack](http://devcenter.heroku.com/articles/buildpack) for Java apps.

## Heroku pre-requisites

This technology exploits the features of Heroku Spaces to securely inter-connect dynos. 

To use this buildpack you need to have access to Heroku Spaces. Outside of Heroku Spaces, Datomic security is not assured.

## Configuring a custom buildpack

`heroku buildpacks:set https://github.com/opengrail/heroku-buildpack-datomic -a myapp`

For more details see the [Heroku web site on third party buildpacks](https://devcenter.heroku.com/articles/third-party-buildpacks#using-a-custom-buildpack)

## Detection

The buildpack will detect that you wish to start a Datomic transactor if it has a Procfile that has this line:

`datomic: /app/scripts/start-datomic.sh`

## Configuration

### Datomic free configuration - playtime only!!

By default Datomic free will be started. *Data will not be stored between startups*

You can optionally configure the version of Datomic you wish to deploy (default is `0.9.5327`)

DATOMIC_VERSION `version-number`

### Datomic Pro configuration

You can get a free copy of the [Datomic Pro starter edition](http://www.datomic.com/get-datomic.html) or bring your supported license.

DATOMIC_LICENSE_PASSWORD `license-password`

DATOMIC_LICENSE_USER     `license-user`

DATOMIC_TRANSACTOR_KEY   `license-key`

You can optionally configure the version of Datomic you wish to deploy (default is `0.9.5327`)

DATOMIC_VERSION `version-number`

### Heroku Addons - Pro editions only

To run any of the Pro editions, this buildpack needs you to have a Postgres database. The only Postgres database supported is

Heroku Postgres (free or paid)

## Dyno size

Transactors require a minimum of 1Gb RAM in all cases. In production, 4Gb or more is preferred.

## Dyno count

To manage failover for the Pro edition (not starter or free), 2 Transactors can be started. 

If the lead transactor fails, the other worker can takeover.

When clients connect to the storage they will be automatically transitioned to the new lead transactor.

## ToDo

This is the first buildpack I have made and it relies on native Heroku components.

I would like to add other storage options in the future that are not available on the Heroku platform but are in the same AWS data-centre.

License
-------

Licensed under the MIT License. See LICENSE file.
