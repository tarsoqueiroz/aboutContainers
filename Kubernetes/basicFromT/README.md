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

## 