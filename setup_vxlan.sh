#!/bin/bash

set -e

vrfName=${VRFNAME:-"vrf-blue"}
vni=${VNI:-"42"}
vxlanDstPort=${VXDSTPORT:-"4789"}
vxlanIfName=${VXIFNAME:-"vxlan42"}
brIfName=${BRIFNAME:-"br42"}

hostName=$(hostname)
if [ -z "$hostName" ]; then
  echo "No hostname."
  exit 1
fi

localIp=$(cat data/$hostName/ipcidr | cut -d '/' -f1)
if [ -z "$localIp" ]; then
  echo "No local IP found."
  exit 1
fi

ip link add "$vxlanIfName" type vxlan id "$vni" dstport "$vxlanDstPort" local "$localIp" nolearning

ip link add "$brIfName" type bridge
ip link set "$vxlanIfName" master "$brIfName"
ip link set "$brIfName" type bridge stp_state 0

ip link set "$brIfName" up
ip link set "$vxlanIfName" up
