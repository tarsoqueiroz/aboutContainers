#!/bin/bash

set +e

echo "Deploying sample application"
envsubst < ./resources/httpbin.yaml | kubectl apply -f -
