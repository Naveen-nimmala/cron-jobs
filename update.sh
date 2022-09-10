#!/bin/bash

### Set initial time of file
LTIME=`stat -c %Z /data/..data/my-yaml.yml`

while true    
do
   ATIME=`stat -c %Z /data/..data/my-yaml.yml`

   if [[ "$ATIME" != "$LTIME" ]]
   then    
       /bin/bash /cron-tab/my_config_file.sh
       LTIME=$ATIME
   fi
   sleep 5
done
