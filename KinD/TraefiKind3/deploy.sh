#!/bin/bash

set +e

echo "Deploying sample application"
envsubst < httpbin.yaml | kubectl apply -f -
