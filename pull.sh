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

MYSQLADMIN_PING="mysqladmin ping -u ${LOCAL_DB_USER}";
if [ -n "${LOCAL_DB_PASSWORD}" ]; then
  MYSQLADMIN_PING+=" -p ${LOCAL_DB_PASSWORD}"
fi

if [ ! -e "`which mysqladmin`" ] || [ "`${MYSQLADMIN_PING}`" != "mysqld is alive" ]; then
  echo "MySQL not started."
  exit 0
fi

if [ "$a" = 1 ] ; then
  bash ${ROOT}/bin/pull.sh ${ENVIRONMENT} /
  bash ${ROOT}/bin/db-pull.sh ${ENVIRONMENT}
fi

if [ "${w}" = 1 ] ; then
  echo "===== Downloading WordPress Core ====="
  EXCLUDES=(wp-content)
  bash ${ROOT}/bin/pull.sh ${ENVIRONMENT} / ${EXCLUDES}
fi

if [ "${d}" = 1 ] ; then
  bash ${ROOT}/bin/db-pull.sh ${ENVIRONMENT}
fi

if [ "${t}" = 1 ] ; then
  echo "===== Downloading themes ====="
  bash ${ROOT}/bin/pull.sh ${ENVIRONMENT} /wp-content/themes/
fi

if [ "${p}" = 1 ] ; then
  echo "===== Downloading plugins ====="
  bash ${ROOT}/bin/pull.sh ${ENVIRONMENT} /wp-content/plugins/
fi

if [ "${u}" = 1 ] ; then
  echo "===== Downloading uploads ====="
  bash ${ROOT}/bin/pull.sh ${ENVIRONMENT} /wp-content/uploads/
fi
