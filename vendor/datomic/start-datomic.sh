#!/usr/bin/env bash

########------- START ---##### publish the dyno IP

if [ -z "${REDIS_URL}" ]
then
    echo "REDIS_URL missing but must be set"
    exit 1
fi

DYNO_IP=$(ip -4 -o addr show dev eth1 | awk '{print $4}' | cut -d/ -f1)

REDIS_HOST=`echo ${REDIS_URL} | sed 's|.*@\(.*\):.*|\1|'`

REDIS_PORT=`echo ${REDIS_URL} | sed 's|.*:\(.*\)|\1|'`

REDIS_PASSWORD=`echo ${REDIS_URL} | sed -e 's|redis://\(.*\)@.*:.*|\1|' -e 's|.*:\(.*\)|\1|'`

REDIS="redis-cli -h ${REDIS_HOST} -p ${REDIS_PORT} -a ${REDIS_PASSWORD}"

OK=`echo 'LPUSH datomic "{\"host\": \"'${DYNO_IP}'\", \"port\":'${PORT}'}"' | ${REDIS} | egrep '^[0-9]*$'`

if [ ${OK} == 0 ]
then
    echo "Published Dyno IP to REDIS"
else
    echo "Failed to publish Dyno IP to REDIS - aborting dyno"
    exit 1
fi

########---> TODO: think about how clients can heartbeat this value

########------- END -----##### publish the dyno IP

if [ -z "${SCRIPTS_HOME}" ]
then
    SCRIPTS_HOME=/app/scripts
fi

${SCRIPTS_HOME}/datomic-postgres-setup-checker.sh || {
    echo "Failed to establish whether Postgres is properly setup - aborting dyno"
    exit 1
}

PROPERTIES=${SCRIPTS_HOME}/transactor.properties

DYNO_PROPERTIES=${SCRIPTS_HOME}/${PROPERTIES}.heroku

sed "s/^port=4334/port=$PORT/" ${PROPERTIES} > ${DYNO_PROPERTIES}

unset JAVA_OPTS

# Do not log passwords (Datomic should not do this)

transactor -Xmx512m -Xms256m ${DYNO_PROPERTIES} | sed 's|\(.*\)&password=.*&\(.*\)|\1\&password=*****\&\2|'
