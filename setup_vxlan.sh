#!/bin/bash

set -e

scriptPath=$(realpath $0)
scriptDir=$(dirname $scriptPath)

vni=${VNI:-"42"}
vxlanDstPort=${VXDSTPORT:-"4789"}
vxlanIfName=${VXIFNAME:-"vxlan42"}
brIfName=${BRIFNAME:-"br42"}

hostName=$(hostname)
if [ -z "$hostName" ]; then
  echo "No hostname."
  exit 1
fi

localIp=""
localDev=""
while read -r ipcidr; do
  if [[ "$ipcidr" =~ fe80:* ]]; then
    continue
  fi
  localIp=$(echo $ipcidr | cut -d '/' -f1)
  localDev=$(ip --json a show to $localIp | jq -r '.[] | .ifname')
  break
done < $scriptDir/data/$hostName/ipcidr

if [ -z "$localIp" ]; then
  echo "No local ip found."
  exit 1
fi

# specify dev btw to let it work out correct MTU automatically
ip link add "$vxlanIfName" type vxlan id "$vni" dev "$localDev" dstport "$vxlanDstPort" local "$localIp" nolearning

ip link add "$brIfName" type bridge
ip link set "$vxlanIfName" master "$brIfName"
ip link set "$brIfName" type bridge stp_state 0

ip link set "$brIfName" up
ip link set "$vxlanIfName" up
