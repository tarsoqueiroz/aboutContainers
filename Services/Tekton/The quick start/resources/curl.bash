kubectl run curl-pod --image=curlimages/curl:latest --command -- sleep infinity
kubectl exec -it curl-pod -- /bin/sh

curl -X POST http://el-5-09-el.default.svc.cluster.local:8080 \
    -H 'Content-Type: application/json' \
    -d '{"firstname":"John", "lastname":"Doe"}'

curl -X POST http://el-5-09-el.default.svc.cluster.local:8080 \
    -H 'Content-Type: application/json' \
    -d '{"firstname":"John", "surname":"Doe"}'
kubectl logs -l eventlistener=5-09-el #-n tekton-pipelines
