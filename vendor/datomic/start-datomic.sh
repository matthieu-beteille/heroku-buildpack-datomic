#!/usr/bin/env bash

if [ -z "${SCRIPTS_HOME}" ]
then
    SCRIPTS_HOME=/app/scripts
fi

cd ${SCRIPTS_HOME}

./datomic-postgres-setup-checker.sh

PROPERTIES=transactor.properties

DYNO_PROPERTIES=/tmp/${PROPERTIES}.heroku

sed "s/^port=4334/port=$PORT/" ${PROPERTIES} > ${DYNO_PROPERTIES}

unset JAVA_OPTS

transactor -Xmx512m -Xms256m ${DYNO_PROPERTIES} | sed 's/\(.*\)&password=.*&\(.*\)/\1\&password=*****\&\2/'


