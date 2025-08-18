#!/bin/bash

CONTAINER_WHITELIST="/usr/local/etc/whitelisted_containers_for_shutdown.txt"
SHUTDOWN_DELAY=600

while docker ps --format '{{.Names}}' | grep -qf $CONTAINER_WHITELIST; do
    sleep 120
done

sleep $SHUTDOWN_DELAY

if ! docker ps --format '{{.Names}}' | grep -qf $CONTAINER_WHITELIST ; then
    if who | grep -qv '^\s*$'; then
        echo "The following users are still logged in - Skipping shutdown"
	awk '{print "- " $1}'
	exit 0
    fi
    echo "No active users or whitelisted containers (${CONTAINER_WHITELIST}). Shutting down."
    systemctl poweroff
fi

echo "The following active containers are whitelisted and are preventing system shutdown:"
docker ps --format '{{.Names}}' | grep -f $CONTAINER_WHITELIST | awk '{print "- " $0}' -
exit 0

