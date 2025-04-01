#!/bin/bash

scriptPath=$(realpath $0)
scriptDir=$(dirname $scriptPath)

bridgesD="$scriptDir/data/$(hostname)/bridges"

if ! [ -d "$bridgesD" ]; then
  echo "No bridges dir found."
  exit 1
fi

for bridgeD in $bridgesD/*; do
  $scriptDir/setup_br.sh $bridgeD
done
