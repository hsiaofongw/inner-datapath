#!/bin/bash

set -e

vxlanIfName=${VXIFNAME:-"vxlan42"}
brIfName=${BRIFNAME:-"br42"}

ip link del "$vxlanIfName"
ip link del "$brIfName"
