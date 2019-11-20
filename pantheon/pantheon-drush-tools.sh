#!/bin/bash
#
#
#  pantheon-drush-tools.sh COMMAND PANTHEON_ENV="test" ARGS
#
#
#
#

#  Parse COMMAND
COMMAND=$1
shift

#  Parse OPTIONS
while getopts "u:s:e:d:p:h" opt
do
  case "${opt}"
  in
    u) PANTHEON_USER=$OPTARG;;
    s) PANTHEON_SITE=$OPTARG;;
    e) PANTHEON_ENV=$OPTARG;;
    d) DRUPAL_USER=$OPTARG;;
    p) DRUSH_PATH=$OPTARG;;
    h)
      echo "Usage: $COMMAND [-h] [-u] [-s] [-e] [-d] [-p]"
      exit 0
      ;;
    :)
      echo "Invalid option: $OPTARG requires an argument" 1>&2
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))

#  Set PANTHEON_USER
if [ -z $PANTHEON_USER ]; then
  export PANTHEON_USER="$(terminus whoami)"
fi

#  Set PANTHEON_SITE (default to first in list)
if [ -z $PANTHEON_SITE ]; then
  export PANTHEON_SITE="$(terminus site:list --field=Name | head -n 1)"
fi

#  Set PANTHEON_ENV
if [ -z $PANTHEON_ENV ]; then
  if [ ! -z "$2" ]; then
    PANTHEON_ENV="$1"
    shift
  else
    PANTHEON_ENV=$(git rev-parse --abbrev-ref HEAD)
  fi
fi

#  Set DRUSH_PATH
if [ -n $DRUSH_PATH ]; then
  DRUSH_PATH="~/.composer/vendor/bin/drush"
fi

#  Set ADDRs
TERMINUS_ADDR="$PANTHEON_SITE.$PANTHEON_ENV"
DRUSH_ADDR="@$TERMINUS_ADDR"

#  Execute
case "$COMMAND" in
  pa)
    terminus aliases
    ;;
  prush)
    drush $DRUSH_ADDR "$@"
    ;;
  plogin)
    drush $DRUSH_ADDR user-login --no-browser $DRUPAL_USER "$@"
    ;;
  psql)
    SQLC=$(drush $DRUSH_ADDR sql-connect --extra="-A --table -e")
    PUSER=$(drush sa $DRUSH_ADDR --format=csv --fields=remote-user --field-labels=0)
    SQLC=$(echo $SQLC | sed -E "s/--host=[^\s ]+/--host=dbserver.$PUSER.drush.in/")
    echo $SQLC "'"$@"'"
    $SQLC "$@"
    ;;
esac
