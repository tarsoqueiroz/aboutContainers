# [Descomplicando o Kubernetes - Expert Mode](https://github.com/badtuxx/CertifiedContainersExpert/tree/main/DescomplicandoKubernetes#descomplicando-o-kubernetes---expert-mode)

## Ambiente para testes e ensaios

```sh
kind create cluster --config ./resources/kind-cluster.yaml

kind get clusters

kind get nodes -n linuxtips

kubectl cluster-info
```

## [Day 1](https://livro.descomplicandokubernetes.com.br/pt/day_one/)

Durante o Day-1 vamos:

- entender o que é um container;
- falar sobre a importância do container runtime e do container engine;
- entender o que é o Kubernetes e sua arquitetura;
- falar sobre o control plane, workers, apiserver, scheduler, controller e muito mais! 

Será aqui que iremos criar o nosso primeiro cluster Kubernetes e realizar o deploy de um pod do Nginx. O Day-1 é para que eu possa me sentir mais confortável com o Kubernetes e seus conceitos iniciais.

```sh
kubectl get ns
kubectl get pod -A
kubectl get pod -o wide

kubectl get pod -n kube-system

kubectl run nginx --image nginx
kubectl get pods
kubectl get pods -o wide
kubectl describe pods nginx

kubectl delete pod nginx1 
kubectl get pods


kubectl run meu-nginx --image nginx --dry-run=client -o yaml > ./resources/pod-template.yaml
kubectl get pods
kubectl apply -f ./resources/pod-template.yaml 

kubectl get pods

kubectl expose pod meu-nginx 

kubectl delete -f ./resources/pod-template.yaml 

kubectl get pods

kubectl run meu-nginx --image nginx --port 80 --dry-run=client -o yaml > ./resources/pod-template2.yaml 
kubectl apply -f ./resources/pod-template2.yaml 

kubectl get pods -o wide

kubectl expose pod meu-nginx 

kubectl get services

kubectl get node -o wide

kubectl get all
kubectl get pod,service -o wide

kubectl delete -f ./resources/pod-template2.yaml 
kubectl delete service meu-nginx 

kubectl get all
```

## [Day 2](https://livro.descomplicandokubernetes.com.br/pt/day_two/)

Durante o Day 2 iremos ver:

- todos os detalhes importantes sobre o menor objeto do Kubernetes, o Pod;
- desde a criação de um simples Pod, passando por Pod com multicontainers, com volumes e ainda com limitação ao consumo de recursos, como CPU ou memória;
- aprender como ver todos os detalhes de um Pod em execução e brincar bastante com nossos arquivos YAML.

```sh
# Criando um Pod
kubectl  run giropops --image=nginx --port=80

# Inspecionando um Pod
kubectl  get pods -o wide
kubectl  get pods giropops -o yaml
kubectl  get pods giropops -o json
kubectl  get pods giropops -o json | jq .
kubectl  get pods giropops -o wide
kubectl  describe pods giropops

# Removendo um Pod
kubectl  delete pods giropops

# Criando um Pod via YAML
cat ./resources/pod.yaml 
kubectl apply -f ./resources/pod.yaml 
kubectl describe pod giropops 

echo # Criando um Pod com mais de um container
cat ./resources/pod-multi-container.yaml
kubectl get pod -o wide
kubectl apply -f ./resources/pod-multi-container.yaml 

kubectl delete -f ./resources/pod.yaml 

kubectl apply -f ./resources/pod-multi-container.yaml 
kubectl get pod -o wide
kubectl describe pod giropops 

# Os comandos attach e exec
kubectl attach giropops -c strigus
kubectl attach giropops -c girus

kubectl get pod -o wide

kubectl exec giropops -c strigus -- ls
kubectl exec giropops -c strigus -it -- sh

kubectl delete -f ./resources/pod-multi-container.yaml 

# Criando um container com limites de memória e CPU
cat ./resources/pod-limitado.yaml

kubectl create -f ./resources/pod-limitado.yaml 
kubectl get pods -o wide
kubectl describe pod giropops 

cat ./resources/pod-ubuntu-limitado.yaml

kubectl create -f ./resources/pod-ubuntu-limitado.yaml 
kubectl delete -f ./resources/pod-limitado.yaml 

kubectl create -f ./resources/pod-ubuntu-limitado.yaml 
kubectl get pod -o wide
kubectl describe pod giropops 
kubectl exec -it giropops -- bash

# Adicionando um volume EmptyDir no Pod
cat ./resources/pod-emptydir.yaml

kubectl apply -f ./resources/pod-emptydir.yaml
kubectl get pod -o wide
kubectl describe pod giropops 

kubectl exec -it giropops -- bash
```

## [Day 3](https://livro.descomplicandokubernetes.com.br/pt/day_three/)

Durante o Day 3 iremos:

- aprender sobre um objeto muito importante no Kubernetes, o Deployment;
- ver todos os detalhes para que possamos ter uma visão completa sobre o que é um Deployment e como ele funciona.

Agora que já sabemos tudo sobre como criar um Pod, acho que já podemos colocar um pouco mais de complexidade no nosso cenário,

```sh
kubectl apply -f resources/deployment.yaml 
kubectl get all

kubectl get deployments.apps -l app=nginx-deployment -o wide
kubectl get pods -l app=nginx-deployment -o wide
kubectl get replicasets.apps -l app=nginx-deployment -o wide

kubectl describe deployments.apps nginx-deployment 

kubectl describe replicasets.apps nginx-deployment-dc6d6dfb9 
kubectl describe pod nginx-deployment-dc6d6dfb9-42s27 

kubectl apply -f resources/deployment.yaml 
kubectl describe deployments.apps nginx-deployment 

kubectl apply -f resources/deployment.yaml 
kubectl describe deployments.apps nginx-deployment 

kubectl rollout status deployment nginx-deployment 

kubectl get pods -l app=nginx-deployment -o yaml

kubectl exec -it nginx-deployment-776b7bf5c7-2r24n -- nginx -v

kubectl apply -f resources/deployment.yaml 
kubectl get pods -l app=nginx-deployment
kubectl exec -it nginx-deployment-859c4697b4-2rj6d -- nginx -v

kubectl apply -f resources/deployment.yaml 
kubectl get pods -l app=nginx-deployment
kubectl exec -it nginx-deployment-776b7bf5c7-2kf5j -- nginx -v

kubectl rollout undo deployment nginx-deployment 
kubectl get pods -l app=nginx-deployment
kubectl exec -it nginx-deployment-859c4697b4-2pcld  -- nginx -v

kubectl rollout history deployment nginx-deployment 
kubectl rollout history deployment nginx-deployment --revision=1
kubectl rollout history deployment nginx-deployment --revision=2

kubectl delete deployments.apps nginx-deployment
```

## [Day 4](https://livro.descomplicandokubernetes.com.br/pt/day_four/)

O Day 4 é dia de falar sobre dois objetos muito importantes no Kubernetes, os ReplicaSets e os DaemonSets:

- quando falamos sobre Deployment é impossível não falar sobre ReplicaSet, pois o Deployment é um objeto que cria um ReplicaSet e o ReplicaSet é um objeto que cria um Pod, veja que tudo está conectado.
- já o DaemonSet é um objeto que cria um Pod e esse Pod é um objeto que fica rodando em todos os nodes do cluster, super importante para nós, pois é com DaemonSet que nós conseguimos garantir que teremos pelo menos um Pod rodando em cada node do cluster.
- vamos falar sobre Readiness Probe, Liveness Probe e Startup Probe, e claro, mostrando todos os detalhes em exemplos práticos e super explicativos.

```sh
# O Deployment e o ReplicaSet
kubectl apply -f resources/replicaset.yaml 

kubectl get deployments.apps -o wide
kubectl get replicasets.apps  -o wide

kubectl scale deployment nginx-deployment --replicas=2

kubectl apply -f resources/replicaset.yaml 
kubectl get replicasets.apps 

kubectl apply -f resources/replicaset.yaml 
kubectl get replicasets.apps 

kubectl describe deployments.apps nginx-deployment 

kubectl rollout undo deployment nginx-deployment 

kubectl get replicasets.apps 
kubectl describe deployments.apps nginx-deployment 

# Criando um ReplicaSet
kubectl apply -f resources/replicaset-alone.yaml 
kubectl get pods

kubectl apply -f resources/replicaset-alone.yaml 
kubectl describe replicasets.apps nginx-replicaset 

kubectl delete pod nginx-replicaset-hzst9 

kubectl describe pod nginx-replicaset-s5dlk 
kubectl describe pod nginx-replicaset-tq2mb 
kubectl get pods -o=jsonpath='{range .items[*]}{"\n"}{.metadata.name}{"\t"}{range .spec.containers[*]}{.image}{"\t"}{end}{end}'

kubectl delete -f resources/replicaset-alone.yaml 

# O DaemonSet
kubectl apply -f resources/node-exporter-daemonset.yaml 

kubectl get daemonsets.apps 
kubectl get pods -l app=node-exporter -o wide

kubectl describe daemonsets.apps node-exporter 

kubectl create daemonset --help

kubectl create daemonset node-exporter --image=prom/node-exporter:latest --port=9100 --host-port=9100 -o yakubectl create daemonset node-exporter --image=prom/node-exporter:latest --port=9100 --host-port=9100 -o yaml --dry-run=client > node-exporter-daemonset.yamml --dry-run=client > resources/node-exporter-daemonset-dry.yaml

kubectl create --help
kubectl create daemonset --help

kubectl create daemonset node-exporter --image=prom/node-exporter:latest --port=9100 --host-port=9100 -o yaml --dry-run=client > resources/node-exporter-daemonset-dry.yaml

kubectl delete daemonsets.apps node-exporter

# As Probes do Kubernetes

```

## [Day 5]()

```sh

```
