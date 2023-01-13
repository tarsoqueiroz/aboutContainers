# Basic about Kubernetes from Tarso

## Deploy your first App on command line

Follow those steps to run your first App by command line:

- Start a local K8s cluster (At K3d, start using `sample.yaml`);
- Deploy the official NGINX container image:

```s
kubectl create deployment nginx-webserver --image=nginx
```

- Verify the deployment was successful:

```s
kubectl get pods -o wide
```

- To deploy the service, the command will look like this:

```s
kubectl expose deployment nginx-webserver --type="NodePort" --port 80
```

- Before we can access the running web server, we have to find out what port it has been mapped to. For that, issue the command:

```s
kubectl get svc nginx-webserver -o wide
```

- So, if you point your web browser to `<IP.of.your.host>:<Port from last cmd>`, you should see the NGINX welcome screen in your browser.

To clean those steps, try it:

```s
kubectl delete svc nginx-webserver
kubectl delete deployment nginx-webserver
```

## Persistent volumes with K3d

> Source: `https://gist.github.com/ruanbekker/bb62d7e2a77493497a2acbc3d0a649d3`

The command line cluster creation was changed by this:

```s
k3d cluster create k3d-cluster --volume $PWD/disk-k3dvol:/data --port "80:80" --agents 2
```

Populating to test avaliability of private and public volumes:

```s
# At node server-0 (docker exec -it k3d-k3dvol-server-0 sh)
echo $(hostname) >> /disk.prv/byserver0.disk.prv.txt
echo $(hostname) >> /disk.pub/byserver0.disk.pub.txt

# At node agent-0  (docker exec -it k3d-k3dvol-agent-0 sh)
echo $(hostname) >> /disk.prv/byagent0.disk.prv.txt
echo $(hostname) >> /disk.pub/byagent0.disk.pub.txt

# At node agent-1  (docker exec -it k3d-k3dvol-agent-1 sh)
echo $(hostname) >> /disk.prv/byagent1.disk.prv.txt
echo $(hostname) >> /disk.pub/byagent1.disk.pub.txt

# At node agent-2  (docker exec -it k3d-k3dvol-agent-2 sh)
echo $(hostname) >> /disk.prv/byagent2.disk.prv.txt
echo $(hostname) >> /disk.pub/byagent2.disk.pub.txt
```

```s
kubectl apply -f ./manifests/k3dvol-app.yaml

kubectl get pv -o wide
kubectl get pvc -o wide

kubectl get  pods -o wide
kubectl exec -it echo-<POD_ID> sh
# At container
/data # echo $(hostname) >> /data/byechocontainer.data.txt
/data # cat /data/byechocontainer.data.txt 

kubectl delete pod echo-<POD_ID>

kubectl get  pods -o wide
kubectl exec -it echo-<POD_ID> sh
# At container
/data # echo $(hostname) >> /data/byechocontainer.data.txt
/data # cat /data/byechocontainer.data.txt 
```
