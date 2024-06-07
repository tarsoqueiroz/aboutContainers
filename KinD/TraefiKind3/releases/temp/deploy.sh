#!/bin/bash

set +e

echo "Deploying sample app:"
envsubst < httpbin.yaml | kubectl apply -f -
