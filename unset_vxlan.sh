#!/bin/bash

set -e

vxlanIfName=${VXIFNAME:-"vxlan42"}

ip link del "$vxlanIfName"
