#!/bin/bash

for f in data/*; do
  ip=$(cat $f/ipcidr | cut -d '/' -f1)
  ip vrf exec vrf-blue ping -c1 $ip
done
