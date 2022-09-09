#!/bin/bash

cat /etc/crontab > /mycron


readarray identityMappings < <(yq -r '.identitymappings[].name' /data/my-yaml.yml )
len=${#identityMappings[@]}
for (( i=0; i<$len; i++ )); do 
   echo "$(yq -r ".identitymappings[${i}].time" /data/my-yaml.yml) curl --user airflow:PASSWORD -X POST https://STACK_PREFIX-internal-airflow.HOST_ZONE_NAME/api/experimental/dags/"${identityMappings[i]}"/dag_runs -H 'Cache-Control: no-cache' -H 'Content-Type: application/json' -d "{\"conf\":\"{\\\"RUN_DATE\\\":\\\"$(date +%Y%m%d)\\\"}\"}" | jq '.brand' >> /tmp/out.txt " >> /mycron
done

crontab /mycron

sleep infinity
