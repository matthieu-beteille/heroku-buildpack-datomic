#!/usr/bin/env bash

# We got here so now we can do the work...

if [ -z "${SCRIPTS_HOME}" ]
then
    SCRIPTS_HOME=/app/scripts
fi

${SCRIPTS_HOME}/datomic-postgres-setup-checker.sh

PROPERTIES=${SCRIPTS_HOME}/transactor.properties

DYNO_PROPERTIES=${SCRIPTS_HOME}/${PROPERTIES}.heroku

## Put this in the datomic properties and it will take care of failover

DYNO_IP=$(ip -4 -o addr show dev eth1 | awk '{print $4}' | cut -d/ -f1)

sed -e "s/^host=localhost/host=${DYNO_IP}" -e "s/^port=4334/port=${PORT}/" ${PROPERTIES} > ${DYNO_PROPERTIES}

unset JAVA_OPTS

# Do not log passwords (Datomic should not do this)

transactor -Xmx512m -Xms256m ${DYNO_PROPERTIES} | sed 's|\(.*\)&password=.*&\(.*\)|\1\&password=*****\&\2|'
