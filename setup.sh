#!/bin/bash

wgIfName=vrf-blue-wg0
vrfName=vrf-blue
vRouteTable=42

ip link add "$vrfName" type vrf table "$vRouteTable"
ip link add "$wgIfName" type wireguard
ip link set "$wgIfName" master "$vrfName"
ip link set "$wgIfName" up

listenPort=$(cat data/$(hostname)/listenport)
wg set "$wgIfName" listen-port $listenPort
wg set "$wgIfName" private-key data/$(hostname)/.private/privkey

for f in data/*; do
  ipCidr=$(cat $f/ipcidr)
  if [ "$(hostname)" = $(basename $f) ]; then
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

ipcidr=$(cat data/$(hostname)/ipcidr)
ip addr add $ipcidr dev "$wgIfName"
ip link set "$vrfName" up
