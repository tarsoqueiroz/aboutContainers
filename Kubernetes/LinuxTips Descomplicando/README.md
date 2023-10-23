# [Descomplicando o Kubernetes - Expert Mode](https://github.com/badtuxx/CertifiedContainersExpert/tree/main/DescomplicandoKubernetes#descomplicando-o-kubernetes---expert-mode)

## Ambiente para testes e ensaios

```sh
kind create cluster --config ./resources/kind-cluster.yaml

kind get clusters

kind get nodes -n linuxtips

kubectl cluster-info
```

## [Day 1](https://livro.descomplicandokubernetes.com.br/pt/day_one/)

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

```sh

```
