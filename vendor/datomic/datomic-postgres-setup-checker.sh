#!/usr/bin/env bash

exists=`psql $DATABASE_URL < datomic-table-exists-query.sql | grep '(1 row)'`

echo -n "-----> Checking Datomic <-> Postgres setup ... "

if [ -n "${exists}" ]
then
    echo "done"
else
    [ -z "${JDBC_DATABASE_USERNAME}" ] && echo "JDBC_DATABASE_USERNAME is not known - stopping" && exit 1

    INPUT=postgres-setup.sql
    TABLE_SETUP=/tmp/${INPUT}.${JDBC_DATABASE_USERNAME}

    sed "s/|owner|/$JDBC_DATABASE_USERNAME/" ${INPUT} > ${TABLE_SETUP}

    created=`psql $DATABASE_URL < ${TABLE_SETUP} | grep ALTER`

    if [ -n "$created" ]
    then
        echo "done"
    else
        echo "*fail*"
        exit 1
    fi
fi

