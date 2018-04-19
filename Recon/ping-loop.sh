#!/bin/bash

for ip in $(seq 1 254); do 
ping 10.11.1.$ip -c 1 | grep "ttl" | cut -d" " -f4 | cut -d":" -f1 & 
done
