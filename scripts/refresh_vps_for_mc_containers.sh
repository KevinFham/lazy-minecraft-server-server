#!/bin/bash

CONTAINER_WHITELIST="/usr/local/etc/whitelisted_containers_for_shutdown.txt"
VPS_REFRESH_ENDPOINT=""
DELAY=120

while docker ps --format '{{.Names}}' | grep -qf $CONTAINER_WHITELIST; do
    sleep $DELAY
    if [ "$(curl -X GET $VPS_REFRESH_ENDPOINT | jq -r '.code')" = "0" ] ; then
        curl -X PUT -H 'Content-Type: application/json' -d '{"action":"refreshVps"}' $VPS_REFRESH_ENDPOINT > /dev/null
    else
        curl -X PUT -H 'Content-Type: application/json' -d '{"action":"startVps"}' $VPS_REFRESH_ENDPOINT > /dev/null
    fi
done

sleep $DELAY
exit 0

