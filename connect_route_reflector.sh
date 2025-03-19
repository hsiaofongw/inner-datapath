#!/bin/bash

set -e

scriptPath=$(realpath $0)
scriptDir=$(dirname $scriptPath)

HOST=routereflector CONTAINER=routereflector $scriptDir/setup_wg.sh
