#!/bin/bash

scriptPath=$(realpath $0)
scriptDir=$(dirname $scriptPath)

netns=frr

docker run \
  --privileged \
  --network host \
  --rm \
  -it \
  --name frr \
  -v $scriptDir/data/$(hostname)/frr/etc:/etc/frr/$netns \
  quay.io/frrouting/frr:10.2.1
