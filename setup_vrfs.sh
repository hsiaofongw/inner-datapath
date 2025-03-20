#!/bin/bash

set -e

scriptPath=$(realpath $0)
scriptDir=$(dirname $scriptPath)

container=${CONTAINER:-"frr"}
echo "container: $container"

brname=${BRNAME:-"br42"}
echo "containerbr: $brname"

netns=$(docker inspect $container --format {{.NetworkSettings.SandboxKey}})
echo "netns: $netns"

for hostdir in $scriptDir/data/$(hostname); do
  host=$(basename $hostdir)
  echo "host: $host"

  if ! [ -d $hostdir/vrfs ]; then
    continue
  fi

  for vrfdir in $hostdir/vrfs/*; do
    vrfname=$(basename $vrfdir)
    echo "vrfname: $vrfname"

    routetable=$(cat $vrfdir/tableid)
    echo "tableid: $routetable"

    vethid=$(openssl rand -hex 3)
    echo "vethid: $vethid"

    vethname=veth-$vethid
    vethpeer=$vethname
    echo "veth: $vethname"
    echo "vethpeer: $vethpeer"

    # setup vrf
    ip link add "$vrfname" type vrf table "$routetable"
    ip link set "$vrfname" up

    # setup veth pair
    ip link add $vethname type veth peer $vethpeer netns "$netns"
    nsenter "--net=$netns" ip link set $vethpeer up
    nsenter "--net=$netns" ip link set $vethpeer master "$brname"
    ip link set $vethname master "$vrfname"
    ip link set $vethname up

    # configure addresses
    while read -r ipcidr; do
      echo "ipcidr: $ipcidr"
      ip a add "$ipcidr" dev "$vethname"
    done < $vrfdir/ipcidr

  done
done
