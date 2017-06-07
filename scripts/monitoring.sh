#!/usr/bin/env bash

# Larry Smith Jr.
# @mrlesmithjr
# http://everythingshouldbevirtual.com

# Turn on verbose execution
set -x

BACKEND_NET="monitoring"
CADVISOR_IMAGE="google/cadvisor:v0.24.1"
ELASTICSEARCH_IMAGE="elasticsearch:2.4"
ELK_ES_SERVER_PORT="9200"
ELK_ES_SERVER="escluster"
ELK_REDIS_SERVER="redis"
FRONTEND_NET="elasticsearch-frontend"
KIBANA_IMAGE="kibana:4.6.3"
LABEL_GROUP="monitoring"

# Check/create Backend Network if missing
docker network ls | grep $BACKEND_NET
RC=$?
if [ $RC != 0 ]; then
  docker network create -d overlay $BACKEND_NET
fi

# Check for running cadvisor and spinup if not running
docker service ls | grep cadvisor
RC=$?
if [ $RC != 0 ]; then
  docker service create --name cadvisor \
    --mount type=bind,source=/var/lib/docker/,destination=/var/lib/docker:ro \
    --mount type=bind,source=/var/run,destination=/var/run:rw \
    --mount type=bind,source=/sys,destination=/sys:ro \
    --mount type=bind,source=/,destination=/rootfs:ro \
    --label org.label-schema.group="$LABEL_GROUP" \
    --network $BACKEND_NET \
    --mode global \
    --publish 8080:8080 \
    $CADVISOR_IMAGE
fi

# Spin up official Elasticsearch Docker image
docker service ls | grep $ELK_ES_SERVER
RC=$?
if [ $RC != 0 ]; then
  docker service create \
    --endpoint-mode dnsrr \
    --mode global \
    --name $ELK_ES_SERVER \
    --network $BACKEND_NET \
    --update-delay 60s \
    --update-parallelism 1 \
    $ELASTICSEARCH_IMAGE \
    elasticsearch \
    -Des.discovery.zen.ping.multicast.enabled=false \
    -Des.discovery.zen.ping.unicast.hosts=$ELK_ES_SERVER \
    -Des.gateway.expected_nodes=3 \
    -Des.discovery.zen.minimum_master_nodes=2 \
    -Des.gateway.recover_after_nodes=2 \
    -Des.network.bind=_eth0:ipv4_
fi

docker service ls | grep "es-lb"
RC=$?
if [ $RC != 0 ]; then
# Give ES time to come up and create cluster
  sleep 5m
  docker service create \
    --name "es-lb" \
    --network $BACKEND_NET \
    --publish 9200:9200 \
    -e BACKEND_SERVICE_NAME=$ELK_ES_SERVER \
    -e BACKEND_SERVICE_PORT="9200" \
    -e FRONTEND_SERVICE_PORT="9200" \
    mrlesmithjr/nginx-lb:ubuntu-tcp-lb
fi

# Spin up offical Kibana Docker image
docker service ls | grep kibana
RC=$?
if [ $RC != 0 ]; then
  docker service create \
    --mode global \
    --name kibana \
    --network $BACKEND_NET \
    --publish 5601:5601 \
    -e ELASTICSEARCH_URL=http://$ELK_ES_SERVER:$ELK_ES_SERVER_PORT \
    $KIBANA_IMAGE
fi
