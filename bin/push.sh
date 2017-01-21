#!/usr/bin/env bash

set -e;

ENVIRONMENT=${1}
shift
DIR=${1}
shift

ROOT=$(cd $(dirname $0)/../ && pwd)
CONFIG_PATH=${ROOT}/config.json
. ${ROOT}/bin/variables.sh

_EXCLUDES=${@}
IGNORE=$(cat ${CONFIG_PATH} | jq -r ".ignore[]")
_EXCLUDES+=(${IGNORE})

EXCLUDES=;
for i in ${_EXCLUDES[@]}
do
  EXCLUDES+="--exclude=${i} "
done

rsync -e "ssh -p ${SSH_PORT}" -rlptvz --delete ${EXCLUDES} ${LOCAL_SERVER_PATH}${DIR} ${SSH_USER}@${SSH_HOST}:${SERVER_PATH}${DIR}
