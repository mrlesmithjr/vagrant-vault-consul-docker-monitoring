<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Repo Info](#repo-info)
  - [Cloning Repo](#cloning-repo)
  - [Requirements](#requirements)
  - [Environment](#environment)
    - [IP address assignments](#ip-address-assignments)
  - [Usage](#usage)
  - [cAdvisor](#cadvisor)
  - [Consul](#consul)
  - [Docker](#docker)
  - [Elasticsearch](#elasticsearch)
  - [Filebeat](#filebeat)
  - [Grafana](#grafana)
  - [Kibana](#kibana)
  - [Netdata](#netdata)
  - [Prometheus](#prometheus)
  - [Vault](#vault)
  - [Monitoring Docker Services](#monitoring-docker-services)
  - [License](#license)
  - [Author Information](#author-information)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Repo Info

Spin up a multi-node [Vagrant](https://www.vagrantup.com) environment for
learning/testing monitoring tools for a micro-services world. All provisioning
is automated using [Ansible](https://www.ansible.com).

## Cloning Repo

All Ansible roles are added as submodules, therefore in order to properly clone the repo you must do the following:

```bash
git clone https://github.com/mrlesmithjr/vagrant-vault-consul-docker-monitoring.git --recursive
```

## Requirements

- [Ansible](https://www.ansible.com)
- [VirtualBox](https://www.virtualbox.org)
- [Vagrant](https://www.vagrantup.com)

## Environment

- `node[0:2]` (Consul Servers)
- `node0`
  - Grafana: <http://192.168.250.10:3000>
  - Netdata: <http://192.168.250.10:19999>
  - Prometheus: <http://192.168.250.10:9090>
- `node3` (Vault)
- `node[4:6]` (Docker Swarm Managers)
- `node[7:8]` (Docker Swarm Workers/Consul Clients)

### IP address assignments

- node0 (192.168.250.10)
- node1 (192.168.250.11)
- node2 (192.168.250.12)
- node3 (192.168.250.13)
- node4 (192.168.250.14)
- node5 (192.168.250.15)
- node6 (192.168.250.16)
- node7 (192.168.250.17)
- node8 (192.168.250.18)

## Usage

Spin up [Vagrant](https://www.vagrantup.com/) environment

```bash
vagrant up
```

## [cAdvisor](https://github.com/google/cadvisor)

[Docker](https://www.docker.com/) hosts have exposed metrics for [Prometheus](https://prometheus.io/) consumption.

## [Consul](https://www.consul.io)

Checking Consul member status:

```bash
vagrant ssh node0

vagrant@node0:~$ sudo consul members list
Node   Address              Status  Type    Build  Protocol  DC
node0  192.168.250.10:8301  alive   server  0.8.1  2         dc1
node1  192.168.250.11:8301  alive   server  0.8.1  2         dc1
node2  192.168.250.12:8301  alive   server  0.8.1  2         dc1
node7  192.168.250.17:8301  alive   client  0.8.1  2         dc1
node8  192.168.250.18:8301  alive   client  0.8.1  2         dc1
```

## [Docker](https://www.docker.com)

Checking Docker swarm node status:

```bash
vagrant ssh node5

vagrant@node5:~$ sudo docker node ls
ID                           HOSTNAME  STATUS  AVAILABILITY  MANAGER STATUS
41oybdyk9njn7trhplpohk4tn *  node5     Ready   Active        Leader
4zc9ndv7rurfbgrhfzxs68sux    node4     Ready   Active        Reachable
8c3y3ta5ad56hlhmfzx2wmdgr    node8     Ready   Active
vmmpixn2i401cyhgd5g4l3cfd    node7     Ready   Active
x50d9z0zkloixvijxht1l36we    node6     Ready   Active        Reachable
```

## [Elasticsearch](https://www.elastic.co/)

Running as a [Docker](https://www.docker.com/) swarm service for storing Docker
container logs.

To validate cluster functionality:

```bash
curl http://192.168.250.14:9200/_cluster/health\?pretty\=true

{
  "cluster_name" : "elasticsearch",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 5,
  "number_of_data_nodes" : 5,
  "active_primary_shards" : 5,
  "active_shards" : 10,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 0,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 100.0
}
```

For the above you may also check against the other Docker Swarm hosts.

## [Filebeat](https://www.elastic.co/products/beats/filebeat)

[Docker](https://www.docker.com/) logs for each host sent to [Elasticsearch](https://www.elastic.co/)

## [Grafana](https://grafana.com/)

Log into the Grafana web UI [here](http://192.168.250.10:3000)

username/password: `admin/admin`

Add the Prometheus data source:

- click `Add data source`
- Name: `prometheus`
- type: `Prometheus`
- Url: `http://192.168.250.10:9090`
- click `Add`

## [Kibana](https://www.elastic.co/products/kibana)

Dashboard to view [Docker](https://www.docker.com/) logs

## [Netdata](https://my-netdata.io/)

`node0` is configured as a [Netdata](https://my-netdata.io/) registry for all
over nodes to announce to which are also running [Netdata](https://my-netdata.io/)

## [Prometheus](https://prometheus.io/)

## [Vault](https://www.vaultproject.io)

## Monitoring Docker Services

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

For the above you may also check against the other Docker Swarm hosts.

```bash
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

## License

MIT

## Author Information

Larry Smith Jr.

- [@mrlesmithjr](https://www.twitter.com/mrlesmithjr)
- [EverythingShouldBeVirtual](http://everythingshouldbevirtual.com)
- [mrlesmithr@gmail.com](mailto:mrlesmithjr@gmail.com)
