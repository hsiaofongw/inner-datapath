#!/bin/bash

set -e

scriptPath=$(realpath $0)
scriptDir=$(dirname $scriptPath)
vmHostName=routereflector
wgIfName=routereflector-wg0

netnsKey=$(docker inspect $vmHostName --format '{{.NetworkSettings.SandboxKey}}')
if [ -z "$netnsKey" ]; then
  echo "Can't get netns key."
  exit 1
fi

ip link add $wgIfName type wireguard
