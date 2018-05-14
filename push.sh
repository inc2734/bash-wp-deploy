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

while getopts awdtpue:f: opt
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
    f) f=1
      CONFIG_FILE=$OPTARG
      ;;
  esac
done

if [ "$f" = 1 ]; then
  CONFIG_PATH=${CONFIG_FILE}
else
  CONFIG_PATH=${ROOT}/config.json
fi
if [ ! -e ${CONFIG_PATH} ]; then
  echo "config.json is not found"
  exit 0;
fi

if [ ! -n "${ENVIRONMENT}" ]; then
  echo "Please specify -e option"
  exit 0;
fi

. ${ROOT}/bin/variables.sh

MYSQLADMIN_PING="mysqladmin ping -u ${LOCAL_DB_USER}";
if [ -n "${LOCAL_DB_PASSWORD}" ]; then
  MYSQLADMIN_PING+=" -p${LOCAL_DB_PASSWORD}"
fi

if [ ! -e "`which mysqladmin`" ] || [ "`${MYSQLADMIN_PING}`" != "mysqld is alive" ]; then
  echo "MySQL not started."
  exit 0
fi

if [ "$a" = 1 ] ; then
  bash ${ROOT}/bin/push.sh ${ENVIRONMENT} ${CONFIG_PATH} /
  bash ${ROOT}/bin/db-push.sh ${ENVIRONMENT} ${CONFIG_PATH}
fi

if [ "${w}" = 1 ] ; then
  echo "===== Uploading WordPress Core ====="
  EXCLUDES=(wp-content)
  bash ${ROOT}/bin/push.sh ${ENVIRONMENT} ${CONFIG_PATH} / ${EXCLUDES}
fi

if [ "${d}" = 1 ] ; then
  bash ${ROOT}/bin/db-push.sh ${ENVIRONMENT} ${CONFIG_PATH}
fi

if [ "${t}" = 1 ] ; then
  echo "===== Uploading themes ====="
  bash ${ROOT}/bin/push.sh ${ENVIRONMENT} ${CONFIG_PATH} /wp-content/themes/
fi

if [ "${p}" = 1 ] ; then
  echo "===== Uploading plugins ====="
  bash ${ROOT}/bin/push.sh ${ENVIRONMENT} ${CONFIG_PATH} /wp-content/plugins/
fi

if [ "${u}" = 1 ] ; then
  echo "===== Uploading uploads ====="
  bash ${ROOT}/bin/push.sh ${ENVIRONMENT} ${CONFIG_PATH} /wp-content/uploads/
fi
