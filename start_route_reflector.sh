#!/bin/bash

scriptPath=$(realpath $0)
scriptDir=$(dirname $scriptPath)
vmHostName=routereflector

docker run \
  --privileged \
  --rm \
  -it \
  --name $vmHostName \
  --hostname $vmHostName \
  -v $scriptDir/data/$vmHostName/frr/etc:/etc/frr \
  -v $scriptPath/data:/root/data \
  quay.io/frrouting/frr:10.2.1
