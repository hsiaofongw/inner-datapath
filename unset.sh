#!/bin/bash

wgIfName=vrf-blue-wg0
vRouteTable=42

ip route flush table 42
ip link del "$wgIfName" 

