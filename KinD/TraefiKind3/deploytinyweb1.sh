#!/bin/bash

set +e

echo "Deploying sample application"
envsubst < tinyweb1.yaml | kubectl apply -f -
