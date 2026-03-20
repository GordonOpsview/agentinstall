#!/bin/bash

#[3A[1;35m
                                                           
###########################################################
#                                                         #
#          [1;39mInstall the ITRS Infrastructure Agent   [1;35m       #
#          [0;2;39m   Pipe this script to | bash -s --     [0;1;35m       #
#                                                         #
###########################################################[0m

# Run this script from curl, on the new host

daemons="nginx|httpd|mysqld|dockerd|k8s|kube" # For automatic assignment of host templates 

<?php exec("hostname -f", $outputn, $ret); exec("hostname -I | cut -d\  -f1", $outputi, $ret); ?>
cfgdir="/opt/itrs/infrastructure-agent/cfg/custom"
url="<?php echo "$outputn[0]"; ?>"
ip="<?php echo "$outputi[0]"; ?>"
fqdn=$(hostname -f)

# 1. Download and install the infrastructure agent

if [[ ! -e /opt/itrs/infrastructure-agent ]]; then
  echo -e "\e[1;35m * Downloading agent...\e[0m"
  tmpdir=$(mktemp -d /tmp/XXXXXX)
  case "$(grep -E '^(VERSION_ID|NAME)=' /etc/os-release | tr -d $'\n' )" in
    *Debian*10*                           ) pkg="infrastructure-agent_2.3.00494-1buster1_amd64.deb" ;;
    *Debian*12*                           ) pkg="infrastructure-agent_2.10.11138-1bookworm1_amd64.deb" ;;
    *Ubuntu*18*                           ) pkg="infrastructure-agent_1.3.43440-1bionic1_amd64.deb" ;;
    *Ubuntu*20*                           ) pkg="infrastructure-agent_2.9.07110-1focal1_amd64.deb" ;;
    *Ubuntu*22*                           ) pkg="infrastructure-agent_2.10.11138-1jammy1_amd64.deb" ;;
    *CentOS*7* | *Oracle*7* | *Red*Hat*7* ) pkg="infrastructure-agent-1.3.43440-1.ct7.x86_64.rpm" ;;
    *Oracle*8* | *Red*Hat*8*              ) pkg="infrastructure-agent-2.10.11138-1.el8.x86_64.rpm" ;;
    *Oracle*9* | *Red*Hat*9*              ) pkg="infrastructure-agent-2.10.11138-1.el9.x86_64.rpm" ;;
    *                                     ) echo "Unknown OS"; exit 1 ;;
  esac
  curl -skLo $tmpdir/$pkg https://$url/agent/download/$pkg
  echo -e "\e[1;35m * Installing agent...\e[0m"
  case "${pkg}" in
    *.deb) dpkg -y -i $tmpdir/$pkg ;;
    *.rpm) rpm -y -i $tmpdir/$pkg ;;
  esac
  rm -rf $tmpdir
fi
# 2. Get the cert
if [[ ! -e "$cfgdir/${fqdn}.pem" ]]; then
  echo -e "\e[1;35m * Downloading certificate...\e[0m"
  curl -skLo $cfgdir/${fqdn}.pem "https://$url/agent/getcert.php?fqdn=$fqdn"
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
curl -skL "https://$url/agent/addhost.php?hostname=$(hostname)&hostip=$(hostname -I | cut -d\  -f1)&daemons=$dmns"



#[3A[1;35m
                                                           
###########################################################
#                                                         #
#          [1;39mInstall the ITRS Infrastructure Agent   [1;35m       #
#          [0;2;39m   Pipe this script to | bash -s --     [0;1;35m       #
#                                                         #
###########################################################[0m

# Run this script from curl, on the new host
