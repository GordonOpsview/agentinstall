#!/bin/bash

# Run this script from curl, on the new host

daemons="nginx|mysqld|dockerd|k8s|kube|k3s" # For automatic assignment of host templates 

<?php exec("hostname -f", $outputn, $ret); exec("hostname -I | cut -d\  -f1", $outputi, $ret); ?>
cfgdir="/opt/itrs/infrastructure-agent/cfg/custom"
url="<?php echo "$outputn[0]"; ?>:10001"
ip="<?php echo "$outputi[0]"; ?>"
fqdn=$(hostname -f)

# 1. Download and install the infrastructure agent

if [[ ! -e /opt/itrs/infrastructure-agent ]]; then
  echo -e "\e[1;35m * Downloading agent...\e[0m"
  tmpdir=$(mktemp -d /tmp/XXXXXX)
  case "$(grep -E '^(VERSION_ID|NAME)=' /etc/os-release | tr '\n' ' ')" in
    *Debian*10*                           ) pm="apt"; pkg="buster.deb" ;;
    *Ubuntu*18*                           ) pm="apt"; pkg="bionic.deb" ;;
    *Ubuntu*20*                           ) pm="apt"; pkg="focal.deb" ;;
    *Ubuntu*22*                           ) pm="apt"; pkg="jammy.deb" ;;
    *CentOS*7* | *Oracle*7* | *Red*Hat*7* ) pm="yum"; pkg="ct7.rpm" ;;
    *Oracle*8* | *Red*Hat*8*              ) pm="yum"; pkg="el8.rpm" ;;
    *Oracle*9* | *Red*Hat*9*              ) pm="yum"; pkg="el9.rpm" ;;
    *                                     ) echo "Unknown OS"; exit 1 ;;
  esac
  curl -sLo $tmpdir/infrastructure-agent-$pkg http://$url/downloads/infrastructure-agent-$pkg
  echo -e "\e[1;35m * Installing agent...\e[0m"
  $pm update && $pm makecache
  $pm install -y $tmpdir/infrastructure-agent-$pkg
  rm -rf $tmpdir
fi
# 2. Get the cert
if [[ ! -e "$cfgdir/${fqdn}.pem" ]]; then
  echo -e "\e[1;35m * Downloading certificate...\e[0m"
  curl -sLo $cfgdir/${fqdn}.pem "http://$url/getcert.php?fqdn=$fqdn"
fi

# 3. Edit agent.yml
if ! $(grep "${fqdn}.pem" $cfgdir/agent.yml &>/dev/null); then
  echo -e "\e[1;35m * Editing config...\e[0m"
  cat /opt/itrs/infrastructure-agent/cfg/agent.default.yml | grep '^server:' -A50 | sed -E "
    /allowed_hosts/ s/null/$ip/;
    /(cert|key)_file/ s%null%$cfgdir/${fqdn}.pem%;" >> $cfgdir/agent.yml
fi

# 4. Restart agent
echo -e "\e[1;35m * Restarting agent...\e[0m"
systemctl restart infrastructure-agent.service

# 5. Add opsview host
dmns=$(ps -e | awk '{print $4}' | sort -u | grep -E "($daemons)" | gzip -9 | base64 -w0)
echo -e "\e[1;35m * Adding host to Opsview...\e[0m"
curl -sL "http://$url/addhost.php?hostname=$(hostname)&hostip=$(hostname -I | cut -d\  -f1)&daemons=$dmns"