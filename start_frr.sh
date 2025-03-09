#!/bin/bash

scriptPath=$(realpath $0)
scriptDir=$(dirname $scriptPath)

docker run \
  --privileged \
  --network host \
  --rm \
  -it \
  --name frr \
  -v $scriptDir/data/$(hostname)/frr/etc:/etc/frr \
  quay.io/frrouting/frr:10.2.1
