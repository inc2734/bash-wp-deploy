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

echo "===== Exporting remote database ====="
if [ -n "${SSH_CONFIG}" ]; then
  ssh ${SSH_CONFIG} "mysqldump --host=${DB_HOST} --user=${DB_USER} --password=\"${DB_PASSWORD}\" --default-character-set=utf8 --no-tablespaces ${DB_NAME}" > remote.sql
else
  ssh ${SSH_USER}@${SSH_HOST} -p ${SSH_PORT} "mysqldump --host=${DB_HOST} --user=${DB_USER} --password=\"${DB_PASSWORD}\" --default-character-set=utf8 --no-tablespaces ${DB_NAME}" > remote.sql
fi
echo $(ls -la remote.sql)

echo "===== Exporting local database =========="
wp db export local.sql
wp search-replace ${LOCAL_SERVER_URL} ${SERVER_URL} --url=${LOCAL_SERVER_NAME} --network > /dev/null
wp search-replace ${LOCAL_SERVER_NAME} ${SERVER_NAME} --url=${LOCAL_SERVER_NAME} --network > /dev/null
wp db export for-remote.sql
echo $(ls -la for-remote.sql)
wp db import local.sql

echo "===== Importing to remote database from local database =========="
if [ -n "${SSH_CONFIG}" ]; then
  ssh ${SSH_CONFIG} "mysql --host=${DB_HOST} --user=${DB_USER} --password=\"${DB_PASSWORD}\" --default-character-set=utf8 ${DB_NAME}" < for-remote.sql
else
  ssh ${SSH_USER}@${SSH_HOST} -p ${SSH_PORT} "mysql --host=${DB_HOST} --user=${DB_USER} --password=\"${DB_PASSWORD}\" --default-character-set=utf8 ${DB_NAME}" < for-remote.sql
fi
