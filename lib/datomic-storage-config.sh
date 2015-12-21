#!/usr/bin/env bash

# This script must be source into scripts which have the following ENV vars properly set
# BUILD_DIR SCRIPTS_TARGET_DIR DATOMIC_TRANSACTOR_KEY

OUTPUT_PROPERTIES_FILE=${SCRIPTS_TARGET_DIR}/transactor.properties

configure_storage() {

    STORAGE_TYPE=${DATOMIC_STORAGE_TYPE:-"HEROKU_POSTGRES"}

    case ${STORAGE_TYPE} in

        DYNAMODB)
            configure_ddb
            ;;

        HEROKU_POSTGRES|POSTGRES)
            configure_sql
            ;;

        *)  echo "Unsupported storage type '${STORAGE_TYPE}'" && return 1
            ;;
    esac
}

configure_ddb() {

    echo -n "-----> Configuring Datomic to connect to DynamoDB... "

set -x

    SAMPLE_PROPERTIES_FILE=${BUILD_DIR}/datomic/config/samples/ddb-transactor-template.properties
    COPY_NAME=${PWD}/ddb-transactor-template-COPY.properties
    PATCHED_FILE_NAME=${PWD}/ddb-transactor-template-PATCHED.properties

echo before copy pwd says
pwd

    cp ${SAMPLE_PROPERTIES_FILE} ${COPY_NAME}

    ${BUILD_DIR}/datomic/bin/datomic ensure-transactor ${COPY_NAME} ${OUTPUT_PROPERTIES_FILE} ${PATCHED_FILE_NAME}

    cat ${PATCHED_FILE_NAME} | license_filter > ${OUTPUT_PROPERTIES_FILE}

    echo "done"
}

configure_sql() {

    [ -z "${DATABASE_URL}" ] && {
        echo "You must set DATABASE_URL" && return 1
    }

    echo -n "-----> Configuring Datomic to connect to ${STORAGE_TYPE}... "

    SAMPLE_PROPERTIES_FILE=${BUILD_DIR}/datomic/config/samples/sql-transactor-template.properties

    case ${STORAGE_TYPE} in

        POSTGRES)
            cat ${SAMPLE_PROPERTIES_FILE} |
            license_filter | postgres_filter > ${OUTPUT_PROPERTIES_FILE}
            ;;

        HEROKU_POSTGRES)
            cat ${SAMPLE_PROPERTIES_FILE} |
            license_filter | postgres_filter | heroku_postgres_filter > ${OUTPUT_PROPERTIES_FILE}
            ;;

        *)  echo "Unsupported DB '${DATOMIC_STORAGE_TYPE}'" && return 1
            ;;
    esac

    echo "done"
}

# Notes:
# sed patterns use '|' as delimiters since '/' is found in URLs and license keys
postgres_filter() {
    SQL_URL=`echo ${DATABASE_URL} | sed 's?.*@\(.*\)?jdbc:postgresql://\1?'`
    SQL_USER=`echo ${DATABASE_URL} | sed -e 's?postgres://\(.*\):.*?\1?' -e 's?\(.*\):.*?\1?'`
    SQL_PASSWORD=`echo ${DATABASE_URL} | sed -e 's?postgres://\(.*\):.*?\1?' -e 's?.*:\(.*\)@.*?\1?'`

    sed -e "s|^sql-url=.*|sql-url=${SQL_URL}|"                \
        -e "s|^sql-user=.*|sql-user=${SQL_USER}|"             \
        -e "s|^sql-password=.*|sql-password=${SQL_PASSWORD}|"
}

heroku_postgres_filter() {
    SQL_DRIVER_PARAMS='ssl=true;sslfactory=org.postgresql.ssl.NonValidatingFactory'

    sed "s|.*\(sql-driver-params=\).*|\1${SQL_DRIVER_PARAMS}|"
}


license_filter() {
    sed "s|^license-key=.*|license-key=${TRANSACTOR_LICENSE_KEY}|"
}