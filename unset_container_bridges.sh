#!/bin/bash

scriptPath=$(realpath $0)
scriptDir=$(dirname $scriptPath)

bridgesD="$scriptDir/data/$(hostname)/bridges"

if ! [ -d "$bridgesD" ]; then
  echo "No bridges dir found."
  exit 1
fi

for bridgeD in $bridgesD/*; do
  vethname=$(basename $bridgeD)
  echo vethname: $vethname

  IPCMD="ip"
  if [ -s "$bridgeD/primarycontainer" ]; then
    primarycontainer=$(cat $bridgeD/primarycontainer)
    if [ -n "$primarycontainer" ]; then
      echo "primarycontainer:" $primarycontainer
      primaryns=$(docker inspect $primarycontainer --format {{.NetworkSettings.SandboxKey}})
      if [ -n "$primaryns" ]; then
        echo "primaryns:" $primaryns
        IPCMD="netns --net=$primaryns ip"
      fi
    fi
  fi

  $IPCMD link del $vethname
done
