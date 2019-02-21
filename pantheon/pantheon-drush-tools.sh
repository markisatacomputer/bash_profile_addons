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
while getopts "u:s:e:d:h" opt
do
  case "${opt}"
  in
    u) PANTHEON_USER=$OPTARG;;
    s) PANTHEON_SITE=$OPTARG;;
    e) PANTHEON_ENV=$OPTARG;;
    d) DRUPAL_USER=$OPTARG;;
    h)
      echo "Usage: $COMMAND [-h] [-u] [-s] [-e] [-d]"
      exit 0
      ;;
    :)
      echo "Invalid option: $OPTARG requires an argument" 1>&2
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))


DRUSH_ADDR="@$PANTHEON_USER.$PANTHEON_SITE"


#  Set PANTHEON_ENV
if [ -n $PANTHEON_ENV ]; then
  if [ ! -z "$2" ]; then
    PANTHEON_ENV="$1"
    shift
  else
    PANTHEON_ENV="test"
  fi
fi

#  Execute
case "$COMMAND" in
  prush)
    drush $DRUSH_ADDR.$PANTHEON_ENV "$@"
    ;;
  plogin)
    drush $DRUSH_ADDR.$PANTHEON_ENV user-login $DRUPAL_USER --no-browser "$@"
    ;;
  psql)
    SQLC=$(drush $DRUSH_ADDR.$PANTHEON_ENV sql-connect --extra="-A --table -e")
    echo "Running query on $DRUSH_ADDR.$PANTHEON_ENV"
    $SQLC "$@"
    ;;
esac
