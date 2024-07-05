#!/bin/bash

set -B

for i in {1..1080000}; do

  curl twi1.0a0f122c.nip.io
  curl twi2.0a0f122c.nip.io:8080
  curl twi3.0a0f122c.nip.io:9090
  curl 0a0f122c.nip.io
  curl twi1.0a0f122c.nip.io
  curl twi2.0a0f122c.nip.io:8080
  curl twi3.0a0f122c.nip.io:9090
  sleep .5s

  curl twi1.0a0f122c.nip.io
  curl twi2.0a0f122c.nip.io:8080
  curl twi3.0a0f122c.nip.io:9090
  curl 0a0f122c.nip.io
  curl twi1.0a0f122c.nip.io
  curl twi2.0a0f122c.nip.io:8080
  curl twi3.0a0f122c.nip.io:9090
  curl 0a0f122c.nip.io
  sleep .5s

  curl twi1.0a0f122c.nip.io
  curl twi2.0a0f122c.nip.io:8080
  curl twi3.0a0f122c.nip.io:9090
  curl 0a0f122c.nip.io
  curl twi1.0a0f122c.nip.io
  curl twi2.0a0f122c.nip.io:8080
  curl twi3.0a0f122c.nip.io:9090
  sleep .5s

  curl twi1.0a0f122c.nip.io
  curl twi2.0a0f122c.nip.io:8080
  curl twi3.0a0f122c.nip.io:9090
  curl 0a0f122c.nip.io
  curl twi1.0a0f122c.nip.io
  curl twi2.0a0f122c.nip.io:8080
  curl twi3.0a0f122c.nip.io:9090
  curl high.0a0f122c.nip.io:8080
  sleep .5s

done
