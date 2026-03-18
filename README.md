# agentinstall

#### A small webapp that serves a bash script that automatically installs ITRS Infrastructure Agents on hosts

- Run `./startserver.sh` on an Opsview Orchestrator to start it, or copy the scripts `addhost.php`, `addhost.sh`, `agentinstall.php` and `getcert.php` to web-accessible location.
- Run the command `curl -sLo- https://<orchestrator.hostname>/downloads/agentinstall.php | sudo bash -s --` on new hosts to install and configure the infrastructure agent.
