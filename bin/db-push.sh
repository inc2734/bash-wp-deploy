#!/usr/bin/env bash

set -e;

ENVIRONMENT=${1}
shift

ROOT=$(cd $(dirname $0)/../ && pwd)
CONFIG_PATH=${ROOT}/config.json
. ${ROOT}/bin/variables.sh

cd ${LOCAL_SERVER_PATH}

echo "===== Exporting local database =========="
wp db export local.sql
wp search-replace ${LOCAL_SERVER_URL} ${SERVER_URL} --url=${LOCAL_SERVER_URL} --network > /dev/null
wp search-replace ${LOCAL_SERVER_NAME} ${SERVER_NAME} --url=${LOCAL_SERVER_URL} --network > /dev/null
wp db export for-remote.sql
echo $(ls -la for-remote.sql)
wp db import local.sql

echo "===== Importing to remote database from local database =========="
ssh ${SSH_USER}@${SSH_HOST} -p ${SSH_PORT} "mysql --host=${DB_HOST} --user=${DB_USER} --password=\"${DB_PASSWORD}\" --default-character-set=utf8 ${DB_NAME}" < for-remote.sql
