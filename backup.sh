#!/bin/bash

VERSION=1.0.0

usage() {
  echo "usage: $0 <API_KEY>"
  echo
  echo "Optional arguments"
  echo "   -v,  --version   Show the current version and exit"
  echo "   -h,  --help      Show this help"
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


URL="https://frog.tips/api/2/tips/search"
API_KEY=$1

BACKUP_DIR=backups
CURL_OUT="$BACKUP_DIR/$(date -u +'%Y-%m-%dT%H%M%SZ').json"

[ -d $BACKUP_DIR ] || mkdir $BACKUP_DIR

curl -H "Content-Type: application/json" -H "Authorization: $API_KEY" \
  --fail \
  -X POST \
  -d '{}' \
  --output $CURL_OUT \
  $URL && \
gzip $CURL_OUT
