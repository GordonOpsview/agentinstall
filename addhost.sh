#!/bin/bash

configopt () {
  grep "^$1:" config | cut -d: -f2- | sed 's/^ *//; s/ *$//'
}
OPSVIEW_USER=$(configopt 'user')
OPSVIEW_PASSWORD=$(configopt 'password')

hostname=$1
hostip=$2
daemons="$(echo $3 | base64 -d | gzip -d)"
templates=("Network - Base" "OS - Unix Base" "OS - Opsview Agent" )

for d in $daemons; do
  case "${d}" in
    dockerd         ) templates+=("Application - Docker") ;;
    nginx           ) templates+=("Application - HTTP") ;;
    mysqld          ) templates+=("Database - MySQL Server") ;;
  esac
done

for t in "${templates[@]}"; do
  tlist=$tlist',{"name": "'$t'" }'
done

/opt/opsview/coreutils/bin/opsview_rest --username $OPSVIEW_USER --password $OPSVIEW_PASSWORD --token-file ./.token GET info &>/dev/null
/opt/opsview/coreutils/bin/opsview_rest --token-file ./.token --data-format=json --data='{
  "name": "'$hostname'",
  "ip": "'$hostip'",
  "hosttemplates": [ '${tlist#,}' ]
}' PUT config/host
# /opt/opsview/coreutils/bin/rc.opsview gen_config