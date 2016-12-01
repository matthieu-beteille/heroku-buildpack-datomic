#!/usr/bin/env bash

if [ -z "${SCRIPTS_HOME}" ]
then
    SCRIPTS_HOME=/app/scripts
fi

STORAGE_TYPE=${DATOMIC_STORAGE_TYPE:-"HEROKU_POSTGRES"}

case ${STORAGE_TYPE} in

    DYNAMODB)
        # TODO run a check against DynamoDB
        ;;

    HEROKU_POSTGRES|POSTGRES)
        ${SCRIPTS_HOME}/datomic-postgres-setup-checker.sh
        if [ $? -ne 0 ]
        then
            echo "Failed to establish whether Postgres is properly setup - aborting dyno"
            exit 1
        fi
        ;;

    *)  echo "Unsupported storage type '${STORAGE_TYPE}'" && return 1
        ;;
esac

PROPERTIES=${SCRIPTS_HOME}/transactor.properties

DYNO_PROPERTIES=${PROPERTIES}.heroku

# Discover the IP that this dyno exposes in the Space

DYNO_IP=$(ip -4 -o addr show dev eth1 | awk '{print $4}' | cut -d/ -f1)

sed "s/^host=localhost/host=${DYNO_IP}/" ${PROPERTIES} > ${DYNO_PROPERTIES}

unset JAVA_OPTS

# Ensure Datomic does not log passwords

transactor -Ddatomic.printConnectionInfo=false -Xmx2g -Xms256m ${PROPERTIES}
