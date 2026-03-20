#!/usr/bin/env bash

## Note: This script is a work in progress. Until it's working, you will need to manually run `startserver.sh` to use frankenphp instead

# Run this script on the orchestrator
main () {
  downloadpackages
  patchnginx
  /opt/opsview/coreutils/utils/cx opsview "INSERT INTO contacts (fullname,name,description,realm,encrypted_password,role) VALUES ('Agent Installer','agentinstall','Agent Auto-install User','local','\$2a\$10\$XAPlOlf2TiP/YTjRaDmzKerM2JzCyRyfV4Eq4N4L4/CRHBPDpA9dq',10);"
  # Install from git folder
  echo -e "\e[1;35m * Installing...\e[0m"
  for file in addhost.php addhost.sh agentinstall.php getcert.php config ; do
    cp -f $file /opt/opsview/webapp/docroot/downloads/$file
    chown root:opsview /opt/opsview/webapp/docroot/downloads/$file
  done
  
  echo -e "\n Run the command \e[1;35mcurl -sLo- https://$(hostname -f)/downloads/agentinstall.php | sudo bash -s --\e[0m on new hosts to install and configure the infrastructure agent.\n"
}

downloadpackages () {
  adir="/opt/opsview/webapp/docroot/downloads/agent"
  mkdir -p "$adir"
  for pkg in {"ct7.rpm","el8.rpm","el9.rpm","buster.deb","bionic.deb","focal.deb","jammy.deb"}; do
    if [[ ! -e "$adir/infrastructure-agent-$pkg" ]]; then
      echo -e "\e[1;35m * Downloading package infrastructure-agent-${pkg}...\e[0m"
      curl -sLo $adir/infrastructure-agent-$pkg "https://downloads.opsview.com/infrastructure-agent/latest/infrastructure-agent-${pkg}"
    fi
  done
  chown -R root:opsview $adir
}

patchnginx () {
  echo -e "\e[1;35m * Configuring webapp...\e[0m"
  patch -u -b /opt/opsview/webserver/etc/conf.d/opsview.conf <<EOF
--- opsview.conf.backup
+++ opsview.conf 
@@ -135,6 +135,13 @@
     }
 
     location /downloads {
+        location ~ \.php$ {
+            fastcgi_pass unix:/var/run/php-fpm-opsview.sock;
+            fastcgi_index index.php;
+            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
+            include /opt/opsview/webserver/etc/fastcgi_params;
+            try_files \$uri =404;
+        }
         try_files \$uri @opsview-web;
     }
 
EOF
}

main $@