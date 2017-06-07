#!/usr/bin/env bash
#
# Larry Smith Jr.
# @mrlesmithjr
# http://everythingshouldbevirtual.com

docker service ls | grep redis
RC=$?
if [ $RC != 0 ]; then
  docker service create \
    --name redis \
    -p 6379:6379 \
    mrlesmithjr/redis
fi
