Repo Info
---------
Spin up a multi-node [Vagrant] environment for learning/testing monitoring
tools for a micro-services world. All provisioning is automated using [Ansible].

Requirements
------------

- [Ansible]
- [VirtualBox]
- [Vagrant]

Environment
-----------
- `node[0:2]` (Consul Servers)
- `node0`
  - [Grafana]: <http://192.168.250.10:3000>
  - [Netdata]: <http://192.168.250.10:19999>
  - [Prometheus]: <http://192.168.250.10:9090>
- `node3` (Vault)
- `node[4:6]` (Docker Swarm Managers)
- `node[7:9]` (Docker Swarm Workers/Consul Clients)

Usage
-----

Spin up [Vagrant] environment

```
vagrant up
```

[cAdvisor]
--------

[Docker] hosts have exposed metrics for [Prometheus] consumption

[Consul]
--------

[Elasticsearch]
-------------

Running as a [Docker] swarm service for storing [Docker Logs](#Filebeat)

[Filebeat]
---------

[Docker] logs for each host sent to [Elasticsearch]

[Grafana]
--------

[Kibana]
--------

Dashboard to view [Docker] logs

[Netdata]
---------

`node0` is configured as a [Netdata] registry for all over nodes to announce to
which are also running [Netdata]

[Prometheus]
----------

[Vault]
-------

Monitoring Docker Services
--------------------------
As part of the provisioning of this environment we spin
up the following:
- Elasticsearch cluster:
   - <http://192.168.250.14:9200>
   - <http://192.168.250.15:9200>
   - <http://192.168.250.16:9200>
- Kibana:
  - <http://192.168.250.14:5601>
  - <http://192.168.250.15:5601>
  - <http://192.168.250.16:5601>

```
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
```

License
-------

BSD

Author Information
------------------

Larry Smith Jr.
- [@mrlesmithjr]
- http://everythingshouldbevirtual.com
- mrlesmithjr [at] gmail.com

[@mrlesmithjr]: <https://www.twitter.com/mrlesmithjr>
[Ansible]: <https://www.ansible.com>
[cAdvisor]: <https://github.com/google/cadvisor>
[Consul]: <https://www.consul.io>
[Docker]: <https://www.docker.com/>
[Elasticsearch]: <https://www.elastic.co/>
[Filebeat]: <https://www.elastic.co/products/beats/filebeat>
[Grafana]: <https://grafana.com/>
[Hashicorp]: <https://www.hashicorp.com/>
[Kibana]: <https://www.elastic.co/products/kibana>
[Netdata]: <https://my-netdata.io/>
[Prometheus]: <https://prometheus.io/>
[Vagrant]: <https://www.vagrantup.com/>
[Vault]: <https://www.vaultproject.io>
[Virtualbox]: <https://www.virtualbox.org/>
