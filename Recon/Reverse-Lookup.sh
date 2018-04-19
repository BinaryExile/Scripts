#!/bin/bash

for ip in $(seq 79 92); do 
   host X.Y.Z.$ip | grep "domain" | cut -d " " -f1,5
done
