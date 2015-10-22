#!/usr/bin/env bash

./datomic-postgres-setup-checker.sh

PROPERTIES=/app/transactor.properties

DYNO_PROPERTIES=/tmp/${PROPERTIES}.heroku

sed "s/^port=4334/port=$PORT/" ${PROPERTIES} > ${DYNO_PROPERTIES}

unset JAVA_OPTS

transactor -Xmx512m -Xms256m ${DYNO_PROPERTIES} | sed 's/\(.*\)&password=.*&\(.*\)/\1\&password=*****\&\2/'


