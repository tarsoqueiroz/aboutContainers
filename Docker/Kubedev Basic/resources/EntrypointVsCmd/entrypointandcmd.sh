#!/bin/bash

if [ -z $1 ]
then
  echo "Initializing container without parm..."
else
  echo "Initializing container with parm $1..."
fi
