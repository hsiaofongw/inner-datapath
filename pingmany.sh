#!/bin/bash

for f in data/*; do
  host=$(basename $f)
  echo "ping host: $host"
  while read -r line; do
    ip=$(echo $line | cut -d '/' -f1)
    if [[ "$ip" == fe80:* ]]; then
      ip --json a show to fe80::/64 | jq -r '.[] | .ifname' | while read -r ifname; do
         echo interface: $ifname
	 ping -n -c1 $ip%$ifname
      done
    else
      ping -n -c1 $ip
    fi
  done < $f/ipcidr
done

