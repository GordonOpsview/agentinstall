#!/usr/bin/env bash

# Run this script on the orchestrator

main () {
  # Establish working dir
  wdir=$(realpath $0)
  wdir=${wdir%/*}

  # Install prerequisites
  installphp
  downloadpackages
  unpackscripts

  # Start PHP server
  cd $wdir && nohup php -S 0.0.0.0:10001 &
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

function unpackscripts () {
  if [[ ! -e "$wdir/agentinstall.php" ]]; then
    echo -e "\e[1;35m * Unpacking agentinstall.php...\e[0m"
    cat <<EOF | base64 -d | gzip -d > $wdir/agentinstall.php
H4sIAAAAAAACA5VVYW/bNhD9rl9xYZXYEirRTlc0iecExRJsAbYGSNBhQJoGNHWyOUsUR1JNjWb/
faQkp/aitI0MGKZ4fPfu8e75xQ6dCUlnzCyC4AVc1hLsQhgwXAtlIddVCbzWxUuo/A6CxDtYVMYG
wc8naqEAPyMfEv9GshIhyclLCKvaqtpK90ujjSaPgs6/BomHoJPjIOD5PBN6SmilLBVWGypkrpmx
uua21piwOUpLXRjltbFVSQJHbko6LnxRAVlnvx7dEI96NB6NRmMSCNUbJ9ZxJMj/yeQ0HG4UE3lR
ximcVneyqFgGTGYgpLGsKBo5tulBQy8IRA7X17ADCcK3K4Gbm4nHkQG0rNwJ8gGvx5NXr0uIH/IK
OW+x0zR12yNXN4AtlRcrHJZLi6WCJAPq3tG/midyEZwZhxcO5xrd9hkMPg7/PLu8Or94d3t+ev/u
7R9n0XQAFC2nlUk0FugP3IPVMPggB+A+EXE1OiiA+BRngsl4PIrh6ScCVU4JU9ZpqpbzKZm5e0Kd
ZjgjMJm0SO9ntbR1PD54HpKopOC9SPvP45RXnBX9QPvPAvqbleVqG+gXd0sXV/Gb2OkYX2jGC+wW
l5jFvzHrVy3Qqi7XQNy+SbUqv8J0Jw+2Tv5fr0cwWBz0whxuwRx+H+ZwGwZ+5Im6wXovl9L1LVxc
ET/6wsK4BULDuO9KN7KQmN8rCNsW7h2NJHRUYGGtOqI0dEdo1g2DeTr+iTE6bye2d4pCVUKtMmYR
9vaaVcmWyBlfYLe7nvdk9X3C7oguIdH5OjTIhbOQ/RR+Rds4BkdtNw2ChK3p0fCL959/U4VO+Gf4
ggcUueCugs26NlR+nADIprBzZwAOJHXeeNJ6oP8mnrrj/iqFs8xdYqvcqiw8+x3oXIVs0V6neoiF
vWOa4Scq66KIvlmSz9GUU8lczLcqYRZ+4A+hzZlhzuqizX0PDcXBR4P6E+qjASRvX4/ca4OZt0PS
NDd1d1vdYXbrfd9QMA1ZGgpF2+6nQ6/O/RJX0W0uCnQhuz5kt0fY3QmB4+PHOnRa/pTCJbpu0p2c
QZ8SXURPt5qV89KS2wJ0h9KnRurLFRyD/wBg5dgJ3QcAAA==
EOF
  fi
  if [[ ! -e "$wdir/getcert.php" ]]; then
    echo -e "\e[1;35m * Unpacking getcert.php...\e[0m"
    cat <<EOF | base64 -d | gzip -d > $wdir/getcert.php
H4sIAAAAAAACA6VSTY/TMBC951cMUaS0EtTtgUtLqdDSBSQkkLbiAmjldSaNVdf22pPtLmz/O+Ns
KtqKPWEpSjJ+782bjzcL3/gsK25kbK5U0J5gDqWgrRd8IdZoMUjCUWzKWZYJARfOGFQEAW9bjARe
BrlFwhCzor6tLNN1jEiD4vrDcvW9TLHy5xAWcBKAKZQV1rI1NGHlwrXkW7rUBlkgF84TP/FO404g
KRGjEZ38yOM2f3KyvEfVEgI1CMk+xCf/O03NsS2GFsptt9JWSbuDHtfb6bIm45AlBwfwS+hd8UdA
aoP9JsNwlnWgU4t+o8WNtukNymi09Eph6KXh8ZGFNcGPYpE/J9q1tkG1AV13FfXF4FORFcRWKYyx
bo15yBgz+EuHF3MYD+F3BnwalBWGQflxtfoqJqMJvB6P4ZPlTlhp4ArDHQZYhuBCyWkTA1XjIH9n
AVMUnFJtCJxx16Rp9Bug7bqzlcrStVZpJ/Kez7XNsn1XQqd/DgQZQULldtY4WXXma5a+ZmKkODia
/fC8igvHzrmbqwePUyC8J+GN1Pbg/Rz3Xkfvoibt7BQkkVTNluMzSAktb8Q8L2GU1qX7O8nN8TJ/
Tvgz2jU1vLSMSlpR/zpl97zAvHR/csfjTXfcny8+WZM8Q6jQYL+9iQCy5hlB5AamXmtK7eTTWqPt
5kxuD2gi/ufELyWLVUDuMGP814T32eJt9gdpOBN0JgQAAA==
EOF
  fi
}


main $@

