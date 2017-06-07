#!/usr/bin/env bash
#
# Larry Smith Jr.
# @mrlesmithjr
# http://everythingshouldbevirtual.com

docker service ls | grep viz
RC=$?
if [ $RC != 0 ]; then
  docker service create \
    --name=viz \
    --publish=8080:8080/tcp \
    --constraint=node.role==manager \
    --mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
    dockersamples/visualizer
fi
