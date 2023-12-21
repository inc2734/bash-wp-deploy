#!/usr/bin/env bash

set -e;

# Encoding
DB_CHARSET=$(cat ${CONFIG_PATH} | jq -r ".db_charset")
if [ "${DB_CHARSET}" = "null" ]; then
  DB_CHARSET="utf8"
fi

# Remote
DB_HOST=$(cat ${CONFIG_PATH} | jq -r ".${ENVIRONMENT}.mysql.host")
DB_NAME=$(cat ${CONFIG_PATH} | jq -r ".${ENVIRONMENT}.mysql.name")
DB_USER=$(cat ${CONFIG_PATH} | jq -r ".${ENVIRONMENT}.mysql.user")
DB_PASSWORD=$(cat ${CONFIG_PATH} | jq -r ".${ENVIRONMENT}.mysql.password")

SSH_USER=$(cat ${CONFIG_PATH} | jq -r ".${ENVIRONMENT}.ssh.user")
SSH_HOST=$(cat ${CONFIG_PATH} | jq -r ".${ENVIRONMENT}.ssh.host")
SSH_PORT=$(cat ${CONFIG_PATH} | jq -r ".${ENVIRONMENT}.ssh.port")
SSH_CONFIG=$(cat ${CONFIG_PATH} | jq -r ".${ENVIRONMENT}.ssh.config")

SERVER_PATH=$(cat ${CONFIG_PATH} | jq -r ".${ENVIRONMENT}.server.path")
SERVER_HOST=$(cat ${CONFIG_PATH} | jq -r ".${ENVIRONMENT}.server.host")
SERVER_PORT=$(cat ${CONFIG_PATH} | jq -r ".${ENVIRONMENT}.server.port")
SERVER_PROTOCOL=$(cat ${CONFIG_PATH} | jq -r ".${ENVIRONMENT}.server.protocol")
SERVER_URL="${SERVER_PROTOCOL}://${SERVER_HOST}"
if [ -n "${SERVER_PORT}" ]; then
  SERVER_URL="${SERVER_URL}:${SERVER_PORT}"
fi
SERVER_NAME=${SERVER_HOST}
if [ -n "${SERVER_PORT}" ]; then
  SERVER_NAME="${SERVER_HOST}:${SERVER_PORT}"
fi

# Local
LOCAL_DB_HOST=$(cat ${CONFIG_PATH} | jq -r ".${LOCAL}.mysql.host")
LOCAL_DB_NAME=$(cat ${CONFIG_PATH} | jq -r ".${LOCAL}.mysql.name")
LOCAL_DB_USER=$(cat ${CONFIG_PATH} | jq -r ".${LOCAL}.mysql.user")
LOCAL_DB_PASSWORD=$(cat ${CONFIG_PATH} | jq -r ".${LOCAL}.mysql.password")

LOCAL_SERVER_PATH=$(cat ${CONFIG_PATH} | jq -r ".${LOCAL}.server.path")
LOCAL_SERVER_HOST=$(cat ${CONFIG_PATH} | jq -r ".${LOCAL}.server.host")
LOCAL_SERVER_PORT=$(cat ${CONFIG_PATH} | jq -r ".${LOCAL}.server.port")
LOCAL_SERVER_PROTOCOL=$(cat ${CONFIG_PATH} | jq -r ".${LOCAL}.server.protocol")
LOCAL_SERVER_URL="${LOCAL_SERVER_PROTOCOL}://${LOCAL_SERVER_HOST}"
if [ -n "${LOCAL_SERVER_PORT}" ]; then
  LOCAL_SERVER_URL="${LOCAL_SERVER_URL}:${LOCAL_SERVER_PORT}"
fi
LOCAL_SERVER_NAME=${LOCAL_SERVER_HOST}
if [ -n "${LOCAL_SERVER_PORT}" ]; then
  LOCAL_SERVER_NAME="${LOCAL_SERVER_HOST}:${LOCAL_SERVER_PORT}"
fi
