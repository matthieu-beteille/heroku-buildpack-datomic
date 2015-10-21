#!/usr/bin/env bash

PROPERTIES=/app/transactor.properties

sed "s/^port=4334/port=$PORT/" ${PROPERTIES} > ${PROPERTIES}.heroku

unset JAVA_OPTS

transactor -Xmx512m -Xms256m ${PROPERTIES}.heroku

