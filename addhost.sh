#!/bin/bash

configopt () {
  grep "^$1:" config | cut -d: -f2- | sed 's/^ *//; s/ *$//'
}
OPSVIEW_USER=$(configopt 'user')
OPSVIEW_PASSWORD=$(configopt 'password')
HOSTGROUP=$(/opt/opsview/coreutils/utils/cx opsview "select id from hostgroups where name like '%$(configopt 'hostgroup')%';" | grep -o '[0-9]*')
CLUSTER=$(/opt/opsview/coreutils/utils/cx opsview "select id from monitoringclusters where name like '%$(configopt 'cluster')%';" | grep -o '[0-9]*')

hostname=$1
hostip=$2

tokenfile=$(mktemp /tmp/token.XXX)
# tokenfile=/tmp/opsview_rest_token
curl -sLk -H 'Content-Type: application/json' -X 'application/json' -X POST -d '{"username":"'$OPSVIEW_USER'","password":"'$OPSVIEW_PASSWORD'"}' https://localhost/rest/login | sed 's/token//; s/[^0-9a-f]//g' > $tokenfile
curl -sLk -H "Content-Type: application/json" -H "Accept: application/json" -X POST -H "X-Opsview-Token: $(cat $tokenfile)" --data '{
  "name": "'$hostname'",
  "ip": "'$hostip'",
  "hosttemplates": [
    {"ref": "/rest/config/hosttemplate/1" },
    {"ref": "/rest/config/hosttemplate/176" },
    {"ref": "/rest/config/hosttemplate/222" }
  ],
  "hostgroup": {"ref": "/rest/config/hostgroup/'$HOSTGROUP'" },
  "uncommitted": "0",
  "monitored_by": {"ref": "/rest/config/monitoringcluster/'$CLUSTER'" },
  "icon": {"path": "/static/images/logos/server.png", "name": "SYMBOL - Server" }
}' https://localhost/rest/config/host
curl -ksL -H 'Content-Type: application/json' -H "X-Opsview-Token: $token" -X 'application/json' -X POST "https://localhost/rest/logout" &>/dev/null
rm -f $tokenfile
