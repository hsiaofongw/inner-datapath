#!/bin/bash

set -e

scriptPath=$(realpath $0)
scriptDir=$(dirname $scriptPath)

peerDir=$1
if [ -z "$peerDir" ]; then
  echo "No \$peerDir found in \$1."
  exit 1
fi

syshostname=$(hostname)
hostname=${HOST:-"$syshostname"}
echo hostname: $hostname

defaultCont=frr
cont=${CONTAINER:-"$defaultCont"}
echo containername: $cont

pidNetns=$$
if [ -z "$pidNetns" ]; then
  echo "Can't get current pid."
  exit 1
fi

echo "pidNetns:" $pidNetns

nskey=$(docker inspect frr --format {{.NetworkSettings.SandboxKey}})
nsenter --net=$nskey ip --json link show type wireguard | jq -r '.[]|.ifname' | while read ifname; do
  wgIf=$ifname
  echo wgifname: $wgIf

  nsenter --net=$nskey ip link set netns $pidNetns dev $wgIf

  peerHost=$(cat $peerDir/clearnet)
  peerPort=$(cat $peerDir/listenport)
  peerPubkey=$(cat $peerDir/pubkey)
  peerEndpoint=$peerHost:$peerPort

  IFS=',' mapfile -t lines < $peerDir/allowedips
  ifsPrev=$IFS
  IFS=','
  allowedIps="${lines[*]}"
  IFS=$ifsPrev

  wg set "$wgIf" peer "$peerPubkey" endpoint "$peerEndpoint" allowed-ips $allowedIps

  ip link set "$wgIf" netns "$nskey"
  cat data/$hostname/ipcidr | while read -r ipcidr; do
    nsenter --net=$nskey ip addr add $ipcidr dev "$wgIf"
  done
  nsenter --net=$nskey ip link set "$wgIf" up
done
