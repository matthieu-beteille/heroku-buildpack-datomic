Heroku buildpack to start Datomic
=================================

This is based on the official [Heroku buildpack](http://devcenter.heroku.com/articles/buildpack) for Java apps.

## How it works

The buildpack will detect your app as Datomic if it has a `load.datomic` file in its root directory.


License
-------

Licensed under the MIT License. See LICENSE file.
