#!/usr/bin/env bash

if [ -z "${SCRIPTS_HOME}" ]
then
    SCRIPTS_HOME=/app/scripts
fi

${SCRIPTS_HOME}/datomic-postgres-setup-checker.sh || {
    echo "Failed to establish whether Postgres is properly setup - aborting dyno"
    exit 1
}

PROPERTIES=${SCRIPTS_HOME}/transactor.properties

DYNO_PROPERTIES=${PROPERTIES}.heroku

DYNO_IP=$(ip -4 -o addr show dev eth1 | awk '{print $4}' | cut -d/ -f1)

sed "s/^host=localhost/host=${DYNO_IP}/" ${PROPERTIES} > ${DYNO_PROPERTIES}

unset JAVA_OPTS

# Do not log passwords

transactor -Ddatomic.printConnectionInfo=false -Xmx2g -Xms256m ${DYNO_PROPERTIES}
