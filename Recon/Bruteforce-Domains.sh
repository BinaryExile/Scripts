#!/bin/bash
# https://github.com/danielmiessler/SecLists/tree/master/Discovery/DNS

for name in $(cat list.txt); do 
  host $name.domain.com | grep "has address" | cut -d " " -f1,4
done
