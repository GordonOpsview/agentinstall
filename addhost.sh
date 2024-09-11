#!/bin/bash

#   Change these default vars to your own URL and credentials if you don't want to specify them in the args
################################
OPSVIEW_USER='admin'
OPSVIEW_PASS='initial'
# OPSVIEW_URL='ggs-6101-orc.openstacklocal'
################################

configopt () {
  grep "^$1:" config | cut -d: -f2- | sed 's/^ *//; s/ *$//'
}


hostgroup=$(/opt/opsview/coreutils/utils/cx opsview "select id from hostgroups where name like '%$(configopt 'hostgroup')%';" | grep -o '[0-9]*')

echo $hostgroup

# # method='GET'
# # token=''
# # json_file='/home/ggstuart/Code/rest_api_data.json'

# while [[ $# -gt 0 ]]; do
#   case $1 in
#     -h | --help ) usage; read -n1; exit ;;
#     -u ) shift; OPSVIEW_USER="$1" ;;
#     -p ) shift; OPSVIEW_PASS="$1" ;;
#     -t ) shift; token="$1" ;;
#     -j ) shift; json_file="$1" ;;
#     --username=* ) OPSVIEW_USER="${1#--username=}" ;;
#     --password=* ) OPSVIEW_PASS="${1#--password=}" ;;
#     --json_file=* ) json_file="${1#--json_file=}" ;;
#     GET | POST | PUT | DELETE ) method="$1";;
#     *  ) break ;;
#   esac
#   shift
# done

# [[ ! $1 =~ ^http.* ]] && rest_url="https://${OPSVIEW_URL}/rest/$1" || rest_url="$1"
# rest_url=$(echo $rest_url | sed 's/http:/https:/g' )
# url_prefix=$(echo $rest_url | sed 's/\/rest\/.*$//g' )
# shift

# if [[ -e $json_file ]]; then
#   json_data="$(cat $json_file)"
# elif [[ $# -gt 0 ]]; then
#   json_data="$@"
# else
#   json_data='{}'
# fi

# # token=''

# function rest_login() {
#   curl -ksL -H 'Content-Type: application/json' -X 'application/json' -X POST -d '{"username":"'$OPSVIEW_USER'","password":"'$OPSVIEW_PASS'"}' "$url_prefix/rest/login" | egrep -o '[0-9a-f]{32}' > $tokenfile
# }

# function rest_logout() {
#   curl -ksL -H 'Content-Type: application/json' -H "X-Opsview-Token: $token" -X 'application/json' -X POST "$url_prefix/rest/logout" &>/dev/null
#   rm -f $tokenfile
# }

# #######
# if [[ -z $token ]]; then
#   # tokenfile=$(mktemp /tmp/token.XXX)
#   tokenfile=/tmp/opsview_rest_token
#   # rest_login
#   [[ ! -e $tokenfile ]] || rest_login
#   curl -ksL -H "Content-Type: application/json" -H "Accept: application/json" -X $method -H "X-Opsview-Token: $(cat $tokenfile)" -d "$json_data" "$rest_url" | jq
#   # rest_logout
# else
#   curl -ksL -H "Content-Type: application/json" -H "Accept: application/json" -X $method -H "X-Opsview-Token: $token" -d "$json_data" "$rest_url" | jq
# fi

