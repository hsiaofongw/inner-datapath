#!/bin/bash

set -e

scriptPath=$(realpath $0)
scriptDir=$(dirname $scriptPath)

peerDir=$1
if [ -z "$peerDir" ]; then
  echo "No \$peerDir found in \$1."
  exit 1
fi

defaultCont=frr
cont=${CONTAINER:-"$defaultCont"}
echo containername: $cont

nskey=$(docker inspect frr --format {{.NetworkSettings.SandboxKey}})
nsenter --net=$nskey ip --json link show type wireguard | jq -r '.[]|.ifname' | while read ifname; do
  wgIf=$ifname
  echo wgifname: $wgIf

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
done
