#!/usr/bin/env bash

# Allows to easily spin up a Docker Swarm Mode (1.12+) Portainer
# http://portainer.io/
#
# Larry Smith Jr.
# @mrlesmithjr
# http://everythingshouldbevirtual.com

# Turn on verbose execution
set -x

# Define variables
PERSISTENT_DATA_MOUNT="/vagrant/.portainer_data"
PORTAINER_DATA_MOUNT_SOURCE="$PERSISTENT_DATA_MOUNT/portainer"
PORTAINER_DATA_MOUNT_TARGET="/data"
PORTAINER_DATA_MOUNT_TYPE="bind"

# Check/create Data Mount Targets
if [ ! -d $PORTAINER_DATA_MOUNT_SOURCE ]; then
  mkdir $PORTAINER_DATA_MOUNT_SOURCE
fi

# Check for running portainer and spinup if not running
docker service ls | grep portainer
RC=$?
if [ $RC != 0 ]; then
  docker service create \
    --name portainer \
    --publish 9000:9000 \
    --constraint 'node.role == manager' \
    --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
    portainer/portainer \
    -H unix:///var/run/docker.sock
fi
