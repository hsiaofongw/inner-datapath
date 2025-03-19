#!/bin/bash

set -e

scriptPath=$(realpath $0)
scriptDir=$(dirname $scriptPath)

randId=$(openssl rand -hex 4)
if [ -z "$randId" ]; then
  echo "Can't get rand id"
  exit 1
fi

syshostname=$(hostname)
hostname=${HOST:-"$syshostname"}
echo hostname: $hostname

defaultCont=frr
cont=${CONTAINER:-"$defaultCont"}
echo containername: $cont

wgIf=wg-$randId
echo wgifname: $wgIf

ip link add "$wgIf" type wireguard

listenPort=$(cat $scriptDir/data/$hostname/listenport)
wg set "$wgIf" listen-port $listenPort
wg set "$wgIf" private-key $scriptDir/data/$hostname/.private/privkey

for f in $scriptDir/data/*; do

  if [ "$hostname" = $(basename $f) ]; then
    continue
  fi

  peerHost=$(cat $f/clearnet)
  peerPort=$(cat $f/listenport)
  peerPubkey=$(cat $f/pubkey)
  peerEndpoint=$peerHost:$peerPort
  
  IFS=',' mapfile -t lines < $f/allowedips
  ifsPrev=$IFS
  IFS=','
  allowedIps="${lines[*]}"
  IFS=$ifsPrev

  wg set "$wgIf" peer "$peerPubkey" endpoint "$peerEndpoint" allowed-ips $allowedIps
done

netns=$(docker inspect $cont --format {{.NetworkSettings.SandboxKey}})
if [ -z "$netns" ]; then
  echo "Can't get netns"
  exit 1
fi

echo netns: $netns
ip link set "$wgIf" netns "$netns"
cat data/$hostname/ipcidr | while read -r ipcidr; do
  nsenter --net=$netns ip addr add $ipcidr dev "$wgIf"
done
nsenter --net=$netns ip link set "$wgIf" up
