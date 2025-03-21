#!/bin/bash

scriptPath=$(realpath $0)
scriptDir=$(dirname $scriptPath)

bridgeD=$1
if ! [ -d "$bridgeD" ]; then
  echo "No bridge dir found."
  exit 1
fi

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
if [ -s "$bridgeD/primarycontainer" ]; then
  primarycontainer=$(cat $bridgeD/primarycontainer)
  if [ -n "$primarycontainer" ]; then
    echo "primarycontainer:" $primarycontainer
    primaryns=$(docker inspect $primarycontainer --format {{.NetworkSettings.SandboxKey}})
    if [ -n "$primaryns" ]; then
      echo "primaryns:" $primaryns
      ip link set $vethname netns $primaryns
      IPCMD="nsenter --net=$primaryns ip"
    fi
  fi
fi

echo "IPCMD:" $IPCMD
$IPCMD link set $vethname up

# set MTU to 1370 because it's vxlan over wg over eth
$IPCMD link set mtu 1370 dev $vethname

if [ -s "$bridgeD/ipcidr" ]; then
  while read -r ipcidr; do
    echo ipcidr: $ipcidr
    $IPCMD a add $ipcidr dev $vethname
  done < "$bridgeD/ipcidr"
fi

