#!/bin/bash

set -e

scriptPath=$(realpath $0)
scriptDir=$(dirname $scriptPath)

thisHost=$(hostname)

found=0
for confD in $scriptDir/data/*; do
  basename=$(basename $confD)
  if [ -d "$confD" ] && [[ "$basename" =~ routereflector* ]]; then
    clearnet=$(cat $confD/clearnet)
    if [ "$clearnet" = "$thisHost" ]; then
      echo found RouteReflector: $basename
      found=$((found+1))
      HOST=$basename CONTAINER=$basename $scriptDir/start_frr.sh
    fi
  fi
done

if [ "$found" = "0" ]; then
  echo "No RouteReflector found."
  exit 1
fi

