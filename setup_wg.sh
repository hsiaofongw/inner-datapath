#!/bin/bash

set -e
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

listenPort=$(cat data/$hostname/listenport)
wg set "$wgIf" listen-port $listenPort
wg set "$wgIf" private-key data/$hostname/.private/privkey

for f in data/*; do

  if [ "$hostname" = $(basename $f) ]; then
    continue
  fi

  peerHost=$(cat $f/clearnet)
  peerPort=$(cat $f/listenport)
  peerPubkey=$(cat $f/pubkey)
  peerEndpoint=$peerHost:$peerPort
  
  allowedIps=""
  if [ -s "$f/allowedips" ]; then
    cat $f/allowedips | while read -r allowedip; do
      allowedIps="$allowedIps,$allowedip"
    done
  fi
  
  allowedIpsFlags=""
  if [ -n "$allowedIps" ]; then
    allowedIps=${allowedIps#","}
    allowedIpsFlags="allowed-ips $allowedIps"
  fi

  wg set "$wgIf" peer "$peerPubkey" endpoint "$peerEndpoint" $allowedIpsFlags
done

netns=$(docker inspect frr --format '{{.NetworkSettings.SandboxKey}}')
if [ -z "$netns" ]; then
  echo "Can't get netns key"
  exit 1
fi

echo netns: $netns
ip link set "$wgIf" netns "$netns"
cat data/$hostname/ipcidr | while read -r ipcidr; do
  nsenter "--net=$netns" ip addr add $ipcidr dev "$wgIf"
done
nsenter "--net=$netns" ip link set "$wgIf" up
