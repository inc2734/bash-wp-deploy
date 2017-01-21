#!/usr/bin/env bash

set -e;

ROOT=$(cd $(dirname $0) && pwd)

if [ ! -e "`which jq`" ]; then
  echo "jq is not installed"
  exit 0;
fi

if [ ! -e "`which wp`" ]; then
  echo "WP-CLI is not installed"
  exit 0;
fi

if !(mysql.server status | fgrep -q SUCCESS); then
  echo "MySQL not started."
  exit 0
fi

if [ ! -e ${ROOT}/config.json ]; then
  echo "config.json is not found"
  exit 0;
fi

while getopts awdtpue: opt
do
  case $opt in
    a) a=1
      ;;
    w) w=1
      ;;
    d) d=1
      ;;
    t) t=1
      ;;
    p) p=1
      ;;
    u) u=1
      ;;
    e) e=1
      ENVIRONMENT=$OPTARG
      ;;
  esac
done

if [ ! -n "${ENVIRONMENT}" ]; then
  echo "Please specify -e option"
  exit 0;
fi

CONFIG_PATH=${ROOT}/config.json
. ${ROOT}/bin/variables.sh

if [ "$a" = 1 ] ; then
  bash ${ROOT}/bin/push.sh ${ENVIRONMENT} /
  bash ${ROOT}/bin/db-push.sh ${ENVIRONMENT}
fi

if [ "${w}" = 1 ] ; then
  echo "===== Uploading WordPress Core ====="
  EXCLUDES=(wp-content)
  bash ${ROOT}/bin/push.sh ${ENVIRONMENT} / ${EXCLUDES}
fi

if [ "${d}" = 1 ] ; then
  bash ${ROOT}/bin/db-push.sh ${ENVIRONMENT}
fi

if [ "${t}" = 1 ] ; then
  echo "===== Uploading themes ====="
  bash ${ROOT}/bin/push.sh ${ENVIRONMENT} /wp-content/themes/
fi

if [ "${p}" = 1 ] ; then
  echo "===== Uploading plugins ====="
  bash ${ROOT}/bin/push.sh ${ENVIRONMENT} /wp-content/plugins/
fi

if [ "${u}" = 1 ] ; then
  echo "===== Uploading uploads ====="
  bash ${ROOT}/bin/push.sh ${ENVIRONMENT} /wp-content/uploads/
fi