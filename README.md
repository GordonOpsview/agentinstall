# agentinstall

#### A small webapp that serves a bash script that automatically installs ITRS Infrastructure Agents on hosts

- Run `./startserver.sh` on an Opsview Orchestrator to start it, or copy the scripts `addhost.php`, `addhost.sh`, `agentinstall.php` and `getcert.php` to web-accessible location.
- Run the command `curl -sLo- https://$(hostname -f)/downloads/agentinstall.php | sudo bash -s --` on new hosts to install and configure the infrastructure agent.

## Alternate idea: use the system PHP .

Put the files in `/opt/opsview/webapp/docroot/downloads`, next to the remote collector installer.
Make changes to `/opt/opsview/webserver/etc/conf.d/opsview.conf`

```
    location /downloads {
        location ~ \.php$ {
           # rewrite ^/downloads(/.*)$ $1 break;
           # fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_pass unix:/var/run/php-fpm-opsview.sock;
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            include /opt/opsview/webserver/etc/fastcgi_params;
            try_files $uri =404;
        }
        try_files $uri @opsview-web;
    }
```


The `.patch`:

```
diff --git a/opt/opsview/webserver/etc/conf.d/opsview.conf b/opt/opsview/webserver/etc/conf.d/opsview.conf
index c72a9f3..4192d6d 100644
--- a/opt/opsview/webserver/etc/conf.d/opsview.conf
+++ b/opt/opsview/webserver/etc/conf.d/opsview.conf
@@ -135,6 +135,13 @@ server {
     }
 
     location /downloads {
+        location ~ \.php$ {
+            fastcgi_pass unix:/var/run/php-fpm-opsview.sock;
+            fastcgi_index index.php;
+            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
+            include /opt/opsview/webserver/etc/fastcgi_params;
+            try_files $uri =404;
+        }
         try_files $uri @opsview-web;
     }
 
```
