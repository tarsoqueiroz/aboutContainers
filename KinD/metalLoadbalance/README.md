# LoadBalancer

> `https://kind.sigs.k8s.io/docs/user/loadbalancer/`

## Creating KinD cluster

```Shell
kind cluster create --config metallbtest.yaml
```

## Installing metallb using default manifests

- Create the metallb namespace

```Shell
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/master/manifests/namespace.yaml
```

- Create the memberlist secrets

```Shell
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
```

- Apply metallb manifest

```Shell
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/master/manifests/metallb.yaml
```

- Wait for metallb pods 

to have a status of Running

```Shell
kubectl get pods -n metallb-system --watch
```

- Setup address pool used by loadbalancers

To complete layer2 configuration, we need to provide metallb a range of IP addresses it controls. We want this range to be on the docker kind network.

```Shell
docker network inspect -f '{{.IPAM.Config}}' kind
```

The output will contain a cidr such as 172.19.0.0/16. We want our loadbalancer IP range to come from this subclass. We can configure metallb, for instance, to use 172.19.255.200 to 172.19.255.250 by creating the configmap.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 172.19.171.1-172.19.171.254
```

- Apply the contents

```Shell
kubectl apply -f metallb-configmap.yaml
```

## Using LoadBalancer

The following example creates a loadbalancer service that routes to two http-echo pods, one that outputs foo and the other outputs bar.

```yaml
kind: Pod
apiVersion: v1
metadata:
  name: foo-app
  labels:
    app: http-echo
spec:
  containers:
  - name: foo-app
    image: hashicorp/http-echo:0.2.3
    args:
    - "-text=foo"
---
kind: Pod
apiVersion: v1
metadata:
  name: bar-app
  labels:
    app: http-echo
spec:
  containers:
  - name: bar-app
    image: hashicorp/http-echo:0.2.3
    args:
    - "-text=bar"
---
kind: Service
apiVersion: v1
metadata:
  name: foo-service
spec:
  type: LoadBalancer
  selector:
    app: http-echo
  ports:
  # Default port used by the image
  - port: 5678
```

- Apply the contents

```Shell
kubectl apply -f https://kind.sigs.k8s.io/examples/loadbalancer/usage.yaml
```

Now verify that the loadbalancer works by sending traffic to it's external IP and port.

```Shell
LB_IP=$(kubectl get svc/foo-service -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')
```

-  should output foo and bar on separate lines 

```Shell
for _ in {1..10}; do
  curl ${LB_IP}:5678
done
```
