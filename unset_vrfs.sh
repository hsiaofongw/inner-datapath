#!/bin/bash

set -e

scriptPath=$(realpath $0)
scriptDir=$(dirname $scriptPath)

vrfsdir=$scriptDir/data/$(hostname)/vrfs
if ! [ -d "$vrfsdir" ]; then
  echo "No vrf(s) found"
  exit 1
fi

for vrfdir in $vrfsdir/*; do
  vrfname=$(basename $vrfdir)
  echo "vrfname:" $vrfname

  ip --json link show vrf $vrfname | jq -r '.[]|.ifname' | while read -r ifname; do
    echo "ifname:" "$ifname"
    ip link del $ifname
  done

  ip link del $vrfname
done
