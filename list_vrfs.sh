#!/bin/bash

set -e

scriptPath=$(realpath $0)
scriptDir=$(dirname $scriptPath)

for hostd in $scriptDir/data/*; do
  host=$(basename $hostd)
  echo host: $host

  if ! [ -d $hostd/vrfs ]; then
    continue
  fi

  for vrfd in $hostd/vrfs/*; do
    vrfname=$(basename $vrfd)
    echo vrf: $vrfname

    tableid=$(cat $vrfd/tableid)
    echo tableid: $tableid

    while read -r ipcidr; do
      echo "ipcidr:" $ipcidr
    done < $vrfd/ipcidr
  done
done
