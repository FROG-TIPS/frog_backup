#!/bin/bash

VERSION=2.0.0

usage() {
  echo "usage: $0 <API_KEY> <BACKUP_DIR> <KEEP_THIS_MANY>"
  echo
  echo "BACKUPS GO IN THE BACKUP_DIR (DUH). YOU MUST SUPPLY AN API KEY"
  echo "AN IT MUST HAVE THE :tips.search: PERMISSION (ALSO, DUH)."
  echo
  echo "YOU MUST ALSO SPECIFY HOW MANY BACKUPS WILL BE KEPT WITH KEEP_THIS_MANY."
  echo "OLDER BACKUPS WILL BE PRUNED LOVINGLY BY A TINY JAPANESE GARDENER."
  echo
  echo "THIS IS A SHELL SCRIPT SO IT'S ALREADY SHITTY AND FULL OF BUGS."
  echo "IT'S LIKE GOD FORGOT ABOUT HIS EMBARRASING TEENAGE CREATION BUT"
  echo "SOMEHOW BESTOWED IT UPON MAN WITH GREAT CEREMONY."
  echo
  echo "Optional arguments"
  echo "   -v,  --version   SHOW THE CURRENT VERSION AND EXIT"
  echo "   -h,  --help      SHOW THIS HELP"
  exit 1
}

if [[ "$#" -eq "0" ]]; then
  usage
fi

OPTS=$(getopt -o v::h:: --long version,help -n $0 -- "$@")

while true; do
  case "$1" in
    -v|--version)
      echo "$0, version $VERSION"
      exit
      ;;
    -h|--help)
      usage
      ;;
    *)
      break
      ;;
  esac
done


API_KEY=$1
BACKUP_DIR=$2
KEEP_THIS_MANY=720
URL="https://frog.tips/api/2/tips/search/"
CURL_OUT="$BACKUP_DIR/$(date -u +'%Y-%m-%dT%H%M%SZ').json"

[ -d $BACKUP_DIR ] || mkdir $BACKUP_DIR

echo "---> DOWNLOADING JSON"
curl -H "Content-Type: application/json" -H "Authorization: $API_KEY" \
  --fail \
  -X POST \
  -d '{}' \
  --output $CURL_OUT \
  $URL > /dev/null 2>&1 && \
gzip $CURL_OUT

if [[ "$?" -ne "0" ]]; then
  echo "ERROR: JSON COULD NOT BE DOWNLOADED."
  exit 2
fi

echo "---> ROTATING BACKUPS"
ls -1 $BACKUP_DIR/* | sort -r | tail -n +$KEEP_THIS_MANY | xargs rm > /dev/null 2>&1

echo "DONE."
