#!/bin/bash

set -e

scriptPath=$(realpath $0)
scriptDir=$(dirname $scriptPath)
vmHostName=routereflector
wgIfName=routereflector

ip link add "$wgIfName" type wireguard
ip link set "$wgIfName" up

listenPort=$(cat data/$vmHostName/listenport)
wg set "$wgIfName" listen-port $listenPort
wg set "$wgIfName" private-key data/$vmHostName/.private/privkey

for f in data/*; do
  ipCidr=$(cat $f/ipcidr)
  if [ "$vmHostName" = $(basename $f) ]; then
    continue
  fi

  peerHost=$(cat $f/clearnet)
  peerPort=$(cat $f/listenport)
  peerPubkey=$(cat $f/pubkey)
  peerEndpoint=$peerHost:$peerPort
  

  ip=$(echo $ipCidr | awk -F'/' '{print $1}')
  allowedIp=$(echo $ip/32)

  wg set "$wgIfName" peer "$peerPubkey" endpoint "$peerEndpoint" allowed-ips $allowedIp
done


netnsKey=$(docker inspect $vmHostName --format '{{.NetworkSettings.SandboxKey}}')
if [ -z "$netnsKey" ]; then
  echo "Can't get netns key."
  exit 1
fi

ip link set "$wgIfName" netns "$netnsKey"
nsenter --net=$netnsKey ip link set "$wgIfName" up
ipcidr=$(cat data/$vmHostName/ipcidr)
nsenter --net=$netnsKey ip addr add $ipcidr dev "$wgIfName"
