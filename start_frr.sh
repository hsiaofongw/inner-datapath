#!/bin/bash

scriptPath=$(realpath $0)
scriptDir=$(dirname $scriptPath)

syshostname=$(hostname)
hostname=${HOST:-"$syshostname"}
echo hostname: $hostname

defaultCont=frr
cont=${CONTAINER:-"$defaultCont"}
echo containername: $cont

docker run \
  --privileged \
  --rm \
  -it \
  --name $cont \
  --hostname $hostname \
  -v $scriptDir/data/$hostname/frr/etc:/etc/frr \
  quay.io/frrouting/frr:10.2.1 
