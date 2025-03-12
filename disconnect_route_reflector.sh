#!/bin/bash

set -e

vmHostName=routereflector
wgIfName=routereflector

netnsKey=$(docker inspect $vmHostName --format '{{.NetworkSettings.SandboxKey}}')
if [ -z "$netnsKey" ]; then
  echo "Can't get netns key."
  exit 1
fi

nsenter --net=$netnsKey ip link del "$wgIfName"
