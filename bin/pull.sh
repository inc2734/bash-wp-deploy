#!/usr/bin/env bash

set -e;

ENVIRONMENT=${1}
shift
CONFIG_PATH=${1}
shift
DIR=${1}
shift

ROOT=$(cd $(dirname $0)/../ && pwd)
. ${ROOT}/bin/variables.sh

_EXCLUDES=${@}
IGNORE=$(cat ${CONFIG_PATH} | jq -r ".ignore[]")
_EXCLUDES+=(${IGNORE})

EXCLUDES=;
for i in ${_EXCLUDES[@]}
do
  EXCLUDES+="--exclude=${i} "
done

if [ -n "${SSH_CONFIG}" ]; then
  rsync -rlptvz ${EXCLUDES} ${SSH_CONFIG}:${SERVER_PATH}${DIR} ${LOCAL_SERVER_PATH}${DIR}
else
  rsync -e "ssh -p ${SSH_PORT}" -rlptvz ${EXCLUDES} ${SSH_USER}@${SSH_HOST}:${SERVER_PATH}${DIR} ${LOCAL_SERVER_PATH}${DIR}
fi
