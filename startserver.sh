#!/usr/bin/env bash

# Run this script on the orchestrator

main () {
  # Establish working dir
  wdir=$(realpath $0)
  wdir=${wdir%/*}

  # Install prerequisites
  installphp
  downloadpackages
  # unpackscripts

  # Start PHP server
  cd $wdir && nohup php -S 0.0.0.0:10001 2>/dev/null &
  echo -e "\n Run the command \e[1;35mcurl -sLo- http://$(hostname -f):10001/agentinstall.php | bash -s --\e[0m on new hosts to install and configure the infrastructure agent.\n"
}

##########################

installphp () {
  if ! (which php &>/dev/null); then 
    echo -e "\e[1;35m * Installing php...\e[0m"
    yum install -y php || apt install -y php || exit 1
  fi
}

downloadpackages () {
  mkdir -p $wdir/downloads
  for pkg in {"ct7.rpm","el8.rpm","el9.rpm","buster.deb","bionic.deb","focal.deb","jammy.deb"}; do
    if [[ ! -e "$wdir/downloads/infrastructure-agent-$pkg" ]]; then
      echo -e "\e[1;35m * Downloading package infrastructure-agent-${pkg}...\e[0m"
      curl -sLo $wdir/downloads/infrastructure-agent-$pkg "https://downloads.opsview.com/infrastructure-agent/latest/infrastructure-agent-${pkg}"
    fi
  done
}

main $@

