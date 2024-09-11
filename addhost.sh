#!/bin/bash

configopt () {
  grep "^$1:" config | cut -d: -f2- | sed 's/^ *//; s/ *$//'
}
OPSVIEW_USER=$(configopt 'user')
OPSVIEW_PASSWORD=$(configopt 'password')

hostname=$1
hostip=$2

/opt/opsview/coreutils/bin/opsview_rest --username $OPSVIEW_USER --password $OPSVIEW_PASSWORD --token-file ./.token GET info &>/dev/null
/opt/opsview/coreutils/bin/opsview_rest --token-file ./.token --data-format=json --data='{
  "name": "'$hostname'",
  "ip": "'$hostip'",
  "hosttemplates": [
    {"name": "Network - Base" },
    {"name": "OS - Unix Base" },
    {"name": "OS - Opsview Agent" }
  ],
}' PUT config/host
/opt/opsview/coreutils/bin/rc.opsview gen_config

echo "== $hostname = $hostip ==" >> asdf.log