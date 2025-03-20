#!/bin/bash

set -e

scriptPath=$(realpath $0)
scriptDir=$(dirname $scriptPath)

bridgesD="$scriptDir/data/$(hostname)/bridges"

if ! [ -d "$bridgesD" ]; then
  echo "No bridges dir found."
  exit 1
fi

for bridgeD in $bridgesD/*; do
  vethname=$(basename $bridgeD)
  echo vethname: $vethname
  secondarycontainer=$(cat $bridgeD/secondarycontainer)
  bridgename=$(cat $bridgeD/upstreambridge)
  echo "secondarycontainer:" $secondarycontainer
  echo "bridgename:" $bridgename
  

  secondaryns=$(docker inspect $secondarycontainer --format {{.NetworkSettings.SandboxKey}})
  if [ -z "$secondaryns" ]; then
    echo "Can't get netns of secondary container"
    continue
  fi
  echo "secondaryns:" $secondaryns

  ip link add $vethname type veth peer $vethname netns $secondaryns
  nsenter --net=$secondaryns ip link set $vethname master "$bridgename"
  nsenter --net=$secondaryns ip link set $vethname up

  IPCMD="ip"
  primarycontainer=$(cat $bridgeD/primarycontainer)
  if [ -n "$primarycontainer" ]; then
    echo "primarycontainer:" $primarycontainer
    primaryns=$(docker inspect $primarycontainer --format {{.NetworkSettings.SandboxKey}})
  fi

  if [ -n "$primaryns" ]; then
    echo "primaryns:" $primaryns
    ip link set $vethname netns $primaryns
    IPCMD="netns --net=$primaryns ip"
  fi

  echo "IPCMD:" $IPCMD
  $IPCMD link set $vethname up

  if [ -s "$bridgeD/ipcidr" ]; then
    while read -r ipcidr; do
      $IPCMD a add $ipcidr dev $vethname
    done < "$bridgeD/ipcidr"
  fi
done
