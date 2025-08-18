#!/bin/bash

CONTAINER_WHITELIST="/usr/local/etc/whitelisted_containers_for_shutdown.txt"

if docker ps --format '{{.Names}}' | grep -qf $CONTAINER_WHITELIST ; then
    echo "The following active containers are whitelisted and are preventing system shutdown:"
    docker ps --format '{{.Names}}' | grep -f $CONTAINER_WHITELIST | awk '{print "- " $0}' -
    exit 1
fi

echo "No active users or whitelisted containers (${CONTAINER_WHITELIST}). Allowing shutdown."
exit 0
