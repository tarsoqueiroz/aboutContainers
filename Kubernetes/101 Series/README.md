# Kubernetes 101 Series Articles

> [Index](https://dev.to/leandronsp/series/21979)

## Create cluster

```sh
kind create cluster --config ./kind-cluster.yaml

kind get clusters

kubectl cluster-info
```

## [Kubernetes 101, part I, the fundamentals](https://dev.to/leandronsp/kubernetes-101-part-i-the-fundamentals-23a1)

```sh
kubectl run server --image=nginx
kubectl run client --image=nginx

kubectl get pods -o wide -w

kubectl exec server -- curl localhost

kubectl describe pod server | grep IP

kubectl exec client -- curl 10.244.2.2

kubectl expose pod server --port=80 --target-port=80

kubectl get pods,service -o wide

kubectl exec client -- curl server
```

## [Kubernetes 101, part II, pods](https://dev.to/leandronsp/kubernetes-101-part-ii-pods-19pb)

```sh
kubectl apply -f fifo-pod.yaml 

kubectl get pod,svc -o wide -w

kubectl logs fifo-pod -c server
```

## [Kubernetes 101, part III, controllers and self-healing](https://dev.to/leandronsp/kubernetes-101-part-iii-controllers-and-self-healing-4ki5)

```sh
kubectl apply -f repset-nginx.yaml
kubectl get pod,replicasets,svc -o wide

kubectl delete pod/repset-nginx-g5wrz

kubectl get pod,replicasets,svc -o wide

kubectl delete replicasets.apps/repset-nginx 
kubectl get pod,replicasets,svc -o wide
```

## [Kubernetes 101, part IV, deployments](https://dev.to/leandronsp/kubernetes-101-part-iv-deployments-20m3)

```sh
## Deploying an application
kubectl apply -f deploy-nginx.yaml

kubectl get pod,replicaset,deployment,svc -o wide

kubectl describe deployments.apps deployment-nginx 
kubectl describe replicasets.apps deployment-nginx-7fff4b4656 
kubectl describe pods deployment-nginx-7fff4b4656-8m7hn 

kubectl exec -it deployment-nginx-7fff4b4656-8m7hn -- nginx -v

## Changing image version
kubectl set image deployment/deployment-nginx deploy-nginx=nginx:1.22.1
kubectl get pod -o wide -w

kubectl exec -it deployment-nginx-6746f69b-cj5q7 -- nginx -v

## Trying rollback and rollup
kubectl describe deployments.apps deployment-nginx | grep revision

kubectl rollout undo deployment deployment-nginx 

kubectl describe deployments.apps deployment-nginx | grep revision
kubectl rollout status deployment deployment-nginx 

kubectl exec -it deployment/deployment-nginx -- nginx -v

kubectl rollout undo deployment deployment-nginx --to-revision=2
kubectl rollout status deployment deployment-nginx 

kubectl exec -it deployment/deployment-nginx -- nginx -v

## Scaling replicas
kubectl get pod,replicaset,deploy -o wide

kubectl scale deployment deployment-nginx --replicas=6

kubectl get pod,replicaset,deploy -o wide
```

## [Kubernetes 101, part V, statefulsets](https://dev.to/leandronsp/kubernetes-101-part-v-statefulsets-5dob)

```sh
kubectl apply -f sc-postgre2.yaml
kubectl apply -f pv-postgre2.yaml
kubectl apply -f pvc-postgre2.yaml

kubectl get storageclasses.storage.k8s.io,pv,pvc -o wide

kubectl apply -f deploy-postgre2.yaml 

kubectl get pod,deploy -o wide

kubectl exec deploy-pg2-d6cfc45f5-42g26 -- psql -U postgres -c "CREATE TABLE users (id SERIAL, name VARCHAR);"
kubectl exec deploy-pg2-d6cfc45f5-42g26 -- psql -U postgres -c "SELECT * FROM users"
## Table created on one node of cluster

kubectl rollout restart deployment deploy-pg2

kubectl get pod,deploy -o wide

kubectl exec deploy-pg2-7888b77445-xrwqv  -- psql -U postgres -c "SELECT * FROM users"

kubectl scale deployment deploy-pg2 --replicas=3

kubectl get pod,deployments.apps -o wide

kubectl exec deploy-pg2-7888b77445-xrwqv  -- psql -U postgres -c "SELECT * FROM users" # OK
kubectl exec deploy-pg2-7888b77445-sdg34  -- psql -U postgres -c "SELECT * FROM users" # nOK
kubectl exec deploy-pg2-7888b77445-93sfe  -- psql -U postgres -c "SELECT * FROM users" # nOK

kubectl rollout restart deployment deploy-pg2

kubectl get pod,deployments.apps -o wide

kubectl exec deploy-pg2-6f968b6c7d-7mrfl  -- psql -U postgres -c "SELECT * FROM users" # nOK
kubectl exec deploy-pg2-6f968b6c7d-djwwj  -- psql -U postgres -c "SELECT * FROM users" # OK
kubectl exec deploy-pg2-6f968b6c7d-97n8s  -- psql -U postgres -c "SELECT * FROM users" # nOK

docker exec -it k8s101-worker ls -lah /data/volume/my-pv  # without table
docker exec -it k8s101-worker2 ls -lah /data/volume/my-pv # without table
docker exec -it k8s101-worker3 ls -lah /data/volume/my-pv # with table


```

## That's all folks

Seeya!!!
