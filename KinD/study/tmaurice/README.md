# Sample Kind Cluster

> `https://github.com/thomas-maurice/sample-kind-cluster`
>
> `https://github.com/thomas-maurice/unseal-vault`

## Kubernetes Dashboard

```text
___$ helm install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --namespace kubernetes-dashboard --set protocolHttp=true --set serviceAccount.create=false --set serviceAccount.name=admin-user --set metricsScraper.enabled=true

NAME: kubernetes-dashboard
LAST DEPLOYED: Thu Jan 25 14:26:43 2024
NAMESPACE: kubernetes-dashboard
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
*********************************************************************************
*** PLEASE BE PATIENT: kubernetes-dashboard may take a few minutes to install ***
*********************************************************************************

Get the Kubernetes Dashboard URL by running:
  export POD_NAME=$(kubectl get pods -n kubernetes-dashboard -l "app.kubernetes.io/name=kubernetes-dashboard,app.kubernetes.io/instance=kubernetes-dashboard" -o jsonpath="{.items[0].metadata.name}")
  echo http://127.0.0.1:9090/
  kubectl -n kubernetes-dashboard port-forward $POD_NAME 9090:9090

...
...
...
...

___$ helm install prometheus -n monitoring prometheus-community/kube-prometheus-stack
NAME: prometheus
LAST DEPLOYED: Thu Jan 25 14:44:16 2024
NAMESPACE: monitoring
STATUS: deployed
REVISION: 1
NOTES:
kube-prometheus-stack has been installed. Check its status by running:
  kubectl --namespace monitoring get pods -l "release=prometheus"

Visit https://github.com/prometheus-operator/kube-prometheus for instructions on how to create & configure Alertmanager and Prometheus instances using the Operator.

...
...
...
...

___$ echo "http://grafana.localhost credentials: $(kubectl get secret -n monitoring prometheus-grafana -oyaml | grep admin-user| cut -d: -f2|tr -d \  | base64 -d):$(kubectl get secret -n monitoring prometheus-grafana -oyaml | grep admin-password| cut -d: -f2|tr -d \  | base64 -d)\n"
http://grafana.localhost credentials: admin:prom-operator\n

```
