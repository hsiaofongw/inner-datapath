#!/bin/bash

wgIfName=vrf-blue-wg0
vrfName=vrf-blue
vRouteTable=42

ip route flush table 42
ip link del "$wgIfName" 
ip link del "$vrfName"
