# My tests with Volumes, PV and PVC

## Preparing cluster env

```s
mkdir -p /tmp/tqpv/volserver0
mkdir -p /tmp/tqpv/volserver1
mkdir -p /tmp/tqpv/volservers
mkdir -p /tmp/tqpv/volagent0
mkdir -p /tmp/tqpv/volagent1
mkdir -p /tmp/tqpv/volagents
mkdir -p /tmp/tqpv/volcluster

k3d cluster create --config ./tqpv.yaml
k3d cluster list
k3d node list
kubectl get nodes -o wide

docker container ls
docker container exec k3d-tqpv-server-0 ls /vol
docker container exec k3d-tqpv-server-1 ls /vol
docker container exec k3d-tqpv-agent-0  ls /vol
docker container exec k3d-tqpv-agent-1  ls /vol

docker container exec k3d-tqpv-server-0 env
docker container exec k3d-tqpv-server-1 env
docker container exec k3d-tqpv-agent-0  env
docker container exec k3d-tqpv-agent-1  env

kubectl apply -f ./tqpv-pv.yaml 
kubectl get pv -o wide


```