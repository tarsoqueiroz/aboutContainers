#!/bin/bash

set +e

echo "Deploying tinyweb:v1.0 application"
envsubst < ./resources/tiny1.yaml | kubectl apply -f -
