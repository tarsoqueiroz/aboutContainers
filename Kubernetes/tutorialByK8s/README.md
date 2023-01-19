# Tutorial by Kubernetes.io

> `https://kubernetes.io/docs/tutorials`

## Create a Cluster

To create a K8s cluster for test purpouse, it will be used a sample configuration file from K3D tutorial.

> [`tutor-cluster.yaml`](./manifests/tutor-cluster.yaml)

```s
k3d cluster create -c ./manifests/tutor-cluster.yaml

k3d cluster list

kubectl cluster-info
```

## Learn Kubernetes Basics

> `https://kubernetes.io/docs/tutorials/kubernetes-basics/`

### Deploy an API server

Kubectl basics:

```s
kubectl version --short
kubectl get nodes -o wide
```

Deploy the first API server:

```s
kubectl create deployment kubernetes-bootcamp --image=gcr.io/google-samples/kubernetes-bootcamp:v1

kubectl get deployments -o wide
```

The API server will automatically create an endpoint for each pod, based on the pod name, that is also accessible through the proxy.

View API server running:

```s
# On second terminal, run:
kubectl proxy

# On first terminal,
curl http://localhost:8001/version

export POD_NAME=$(kubectl get pods -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')
echo Name of the Pod: $POD_NAME

curl http://localhost:8001/api/v1/namespaces/default/pods/$POD_NAME/
```

### Explore your App

Troubleshooting with kubectl: you used Kubectl command-line interface. You'll continue to use it to get information about deployed applications and their environments. The most common operations can be done with the following kubectl commands:

- `kubectl get` - list resources
- `kubectl describe` - show detailed information about a resource
- `kubectl logs` - print the logs from a container in a pod
- `kubectl exec` - execute a command on a container in a pod

Check app configuration:

```s
kubectl get pods -o wide

kubectl describe pods
```

Show the app in the terminal:

```s
# On second terminal, run:
kubectl proxy

# On first terminal,
curl http://localhost:8001/version

export POD_NAME=$(kubectl get pods -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')
echo Name of the Pod: $POD_NAME

curl http://localhost:8001/api/v1/namespaces/default/pods/$POD_NAME/proxy/
```

View the container logs:

```s
kubectl logs $POD_NAME
```

Executing command on the container:

```s
kubectl exec $POD_NAME -- env

kubectl exec -ti $POD_NAME -- bash

# Now inside of container, run:
cat server.js

curl localhost:8080

exit
```

### Using a Service to Expose Your App

Create a new service:

```s
kubectl get pods

kubectl get services

kubectl expose deployment/kubernetes-bootcamp --type="NodePort" --port 8080

kubectl get services

kubectl describe services/kubernetes-bootcamp

export NODE_PORT=$(kubectl get services/kubernetes-bootcamp -o go-template='{{(index .spec.ports 0).nodePort}}')
echo NODE_PORT=$NODE_PORT

curl <k3d_IP_node>:$NODE_PORT
```

### Using labels

```s
kubectl describe deployment

kubectl get pods -l app=kubernetes-bootcamp

kubectl get services -l app=kubernetes-bootcamp

export POD_NAME=$(kubectl get pods -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')
echo Name of the Pod: $POD_NAME

kubectl label pods $POD_NAME version=v1

kubectl describe pods $POD_NAME

kubectl get pods -l version=v1
```

### Deleting a service

```s
kubectl delete service -l app=kubernetes-bootcamp

kubectl get services

curl <k3d_IP_node>:$NODE_PORT

kubectl exec -ti $POD_NAME -- curl localhost:8080
```

### Running Multiple Instances of Your App

Scaling a deployment:

```s
kubectl get deployments

kubectl get rs

kubectl scale deployments/kubernetes-bootcamp --replicas=4

kubectl get deployments

kubectl get pods -o wide

kubectl describe deployments/kubernetes-bootcamp
```

Load Balancing

```s
kubectl describe services/kubernetes-bootcamp

export NODE_PORT=$(kubectl get services/kubernetes-bootcamp -o go-template='{{(index .spec.ports 0).nodePort}}')
echo NODE_PORT=$NODE_PORT

curl <k3d_IP_node>:$NODE_PORT
```

Scale Down

```s
kubectl scale deployments/kubernetes-bootcamp --replicas=2

kubectl get deployments

kubectl get pods -o wide
```

### Performing a Rolling Update

Update the version of the app:

```s
kubectl scale deployments/kubernetes-bootcamp --replicas=4
kubectl get deployments

kubectl get pods -o wide

kubectl describe pods

kubectl set image deployments/kubernetes-bootcamp kubernetes-bootcamp=jocatalin/kubernetes-bootcamp:v2

kubectl get pods
```

Verify an update

```s
kubectl describe services/kubernetes-bootcamp

export NODE_PORT=$(kubectl get services/kubernetes-bootcamp -o go-template='{{(index .spec.ports 0).nodePort}}')
echo NODE_PORT=$NODE_PORT

curl <k3d_IP_node>:$NODE_PORT

kubectl rollout status deployments/kubernetes-bootcamp

kubectl describe pods
```

Rollback an update

```s
# v10 don't exist
kubectl set image deployments/kubernetes-bootcamp kubernetes-bootcamp=gcr.io/google-samples/kubernetes-bootcamp:v10

kubectl get deployments

kubectl get pods

kubectl describe pods 

kubectl rollout undo deployments/kubernetes-bootcamp

kubectl get pods

kubectl describe pods
```

## Connecting Applications with Services

> `https://kubernetes.io/docs/tutorials/services/connect-applications-service/`

### Exposing pods to the cluster

```s
kubectl apply -f ./manifests/appwithsvc-deploy.yaml

kubectl get pods -l run=my-nginx -o wide

kubectl get pods -l run=my-nginx -o custom-columns=POD_IP:.status.podIPs
```

### Creating a Service

```s
# By cmd line
kubectl expose deployment/my-nginx
kubectl delete svc/my-nginx

# By manifest
kubectl apply -f ./manifests/appwithsvc-service.yaml 

kubectl get svc my-nginx  -o wide

kubectl describe svc my-nginx 

kubectl get endpointslices -l kubernetes.io/service-name=my-nginx
```

### Accessing the Service

Environment Variables

```s
kubectl get po -o wide

kubectl exec my-nginx-... -- printenv | grep SERVICE

kubectl scale deployment my-nginx --replicas=0

kubectl scale deployment my-nginx --replicas=2

kubectl get pods -l run=my-nginx -o wide

kubectl exec my-nginx-... -- printenv | grep SERVICE
```

DNS

```s
kubectl get service kube-dns --namespace=kube-system

kubectl run curl --image=radial/busyboxplus:curl -i --tty
# Inside container
nslookup my-nginx

# If you need to attach
kubectl attach curl -c curl -i -t
```

### Securing the Service

```s
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout vol.data/nginx.key -out vol.data/nginx.crt -subj "/CN=my-nginx/O=my-nginx"

cat vol.data/nginx.crt | base64 -w 0
cat vol.data/nginx.key | base64 -w 0
# Use the output from the previous commands to adjust appwithsvc-secret.yaml file.
# The base64 encoded value should all be on a single line.

kubectl apply -f ./manifests/appwithsvc-secret.yaml 
kubectl create configmap nginxconfigmap --from-file=./manifests/appwithsvc-default.conf 
kubectl get configmaps,secrets 

kubectl delete deployments,svc my-nginx 
kubectl create -f ./manifests/appwithsvc-secure.yaml 

kubectl get po,svc -o wide
kubectl get pods -l run=my-nginx -o custom-columns=POD_IP:.status.podIPs

kubectl apply -f ./manifests/appwithsvc-curlpod.yaml 
kubectl get po -o wide

kubectl exec curl-deployment-... -- curl https://my-nginx --cacert /etc/nginx/ssl/tls.crt
```

### Exposing the Service

```s
kubectl get svc my-nginx -o yaml | grep nodePort -C 5

kubectl get nodes -o yaml | grep ExternalIP -C 1

# Now, you can change from NodePort to LoadBalancer by command line or manifest file
# kubectl edit svc my-nginx 
# kubectl get svc my-nginx
kubectl apply -f ./manifests/appwithsvc-secure.yaml 

kubectl get svc my-nginx 
```

## Services using source IP

> `https://kubernetes.io/docs/tutorials/services/source-ip/`

## That's all folks

See you soon.
