#!/bin/bash

set -B

# for i in $(seq 1 1000); do curl -s -o /dev/null "http://bookinfo.0a0f122c.nip.io:8080/productpage"; done

for i in {1..360000}; do

  echo ${i}
  curl -s -o /dev/null "http://bookinfo.0a0f122c.nip.io:8080/productpage"
  sleep .33s

done
