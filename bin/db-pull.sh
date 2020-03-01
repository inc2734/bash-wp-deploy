#!/usr/bin/env bash

set -e;

ENVIRONMENT=${1}
shift
CONFIG_PATH=${1}
shift
LOCAL=${1}
shift

ROOT=$(cd $(dirname $0)/../ && pwd)
. ${ROOT}/bin/variables.sh

cd ${LOCAL_SERVER_PATH}

echo "===== Exporting local database =========="
wp db export local.sql
echo $(ls -la local.sql)

echo "===== Exporting remote database ====="
if [ -n "${SSH_CONFIG}" ]; then
  ssh ${SSH_CONFIG} "mysqldump --host=${DB_HOST} --user=${DB_USER} --password=\"${DB_PASSWORD}\" --default-character-set=utf8 ${DB_NAME}" > remote.sql
else
  ssh ${SSH_USER}@${SSH_HOST} -p ${SSH_PORT} "mysqldump --host=${DB_HOST} --user=${DB_USER} --password=\"${DB_PASSWORD}\" --default-character-set=utf8 ${DB_NAME}" > remote.sql
fi
echo $(ls -la remote.sql)

echo "===== Importing to local database from remote database ====="
wp config path || wp config create --dbname=${LOCAL_DB_NAME} --dbuser=${LOCAL_DB_USER} --dbpass=${LOCAL_DB_PASSWORD} --dbhost=${LOCAL_DB_HOST}
wp db check || wp db create
wp db import remote.sql
wp search-replace ${SERVER_URL} ${LOCAL_SERVER_URL} --url=${SERVER_NAME} --network > /dev/null
wp search-replace ${SERVER_NAME} ${LOCAL_SERVER_NAME} --url=${SERVER_NAME} --network > /dev/null
