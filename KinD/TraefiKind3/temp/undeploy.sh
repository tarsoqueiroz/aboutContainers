#!/bin/bash

set +e

echo "unDeploying sample application"
envsubst < ./resources/httpbin.yaml | kubectl delete -f -
