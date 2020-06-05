#!/bin/bash

if [ ! -d "/var/www/html/suitecrm" ]; then
   echo "Deploy suitecrm"
   mv /install-suitecrm /var/www/html/suitecrm
else
   echo "Suitecrm ja instalado. Preservado."
fi

exec bash -c "/run-httpd.sh"


