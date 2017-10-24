#!/usr/bin/env bash

set -e;

ENVIRONMENT=${1}
shift

ROOT=$(cd $(dirname $0)/../ && pwd)
CONFIG_PATH=${ROOT}/config.json
. ${ROOT}/bin/variables.sh

cd ${LOCAL_SERVER_PATH}

echo "===== Exporting remote database ====="
if [ -n "${SSH_CONFIG}" ]; then
  ssh ${SSH_CONFIG} "mysqldump --host=${DB_HOST} --user=${DB_USER} --password=\"${DB_PASSWORD}\" --default-character-set=utf8 ${DB_NAME}" > remote.sql
else
  ssh ${SSH_USER}@${SSH_HOST} -p ${SSH_PORT} "mysqldump --host=${DB_HOST} --user=${DB_USER} --password=\"${DB_PASSWORD}\" --default-character-set=utf8 ${DB_NAME}" > remote.sql
fi
echo $(ls -la remote.sql)

set +e
wp config path
if [ "$?" != 0 ]; then
  echo "===== Generating local wp-config.php ====="
  wp config create --dbname=${LOCAL_DB_NAME} --dbuser=${LOCAL_DB_USER} --dbpass=${LOCAL_DB_PASSWORD} --dbhost=${LOCAL_DB_HOST}
fi
set -e

echo "===== Importing to local database from remote database ====="
wp db import remote.sql
wp search-replace ${SERVER_URL} ${LOCAL_SERVER_URL} --url=${SERVER_NAME} --network > /dev/null
wp search-replace ${SERVER_NAME} ${LOCAL_SERVER_NAME} --url=${SERVER_NAME} --network > /dev/null
