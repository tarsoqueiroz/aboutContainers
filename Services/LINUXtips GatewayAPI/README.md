# Descomplicando Gateway API no Kubernetes

## Sobre

Neste artigo completo da LINUXtips, escrito por Jeferson Fernando, você aprenderá a montar um cluster Kubernetes utilizando o KIND (Kubernetes IN Docker) e a configurar o NGINX Gateway Fabric para gerenciar eficientemente o tráfego das suas aplicações. Abordaremos desde a instalação dos pré-requisitos essenciais, como Docker, kubectl e KIND, até configurações avançadas de roteamento utilizando HTTPRoute, incluindo balanceamento de carga, redirecionamentos, rate limiting e segurança TLS. Além disso, você descobrirá como implantar aplicações, testar o roteamento, escalar serviços e monitorar logs para garantir um ambiente Kubernetes robusto, seguro e escalável. Este artigo da LINUXtips.io é ideal para desenvolvedores e administradores que desejam otimizar a gestão de tráfego em seus clusters Kubernetes de maneira eficiente e segura.

## Sources

- [Descomplicando Gateway API no Kubernetes: Parte 1](https://linuxtips.io/descomplicando-gateway-api-no-kubernetes/)
- [NGINX Gateway Fabric: Github](https://github.com/nginx/nginx-gateway-fabric)
- [NGINX Gateway Fabric: Get started](https://docs.nginx.com/nginx-gateway-fabric/get-started/)
- [NGINX Gateway Fabric: Application routes using HTTP matching conditions (Advanced Routing)](https://docs.nginx.com/nginx-gateway-fabric/how-to/traffic-management/advanced-routing/)

### Pre-requisitos

- **Docker:** Fundamental para a criação de contêineres. Instale o Docker.
- **kubectl:** Ferramenta de linha de comando para interagir com Kubernetes. Instale o kubectl.
- **KIND:** Utilizado para criar clusters Kubernetes dentro de contêineres Docker. Instale o KIND.

### Criando o Cluster com o KIND

- [`kind.yaml`](./kind.yaml)

```bash
kind create cluster --name strigus --config kind.yaml
```

### Instalando o NGINX Gateway Fabric

Aplicando as CRDs:

```bash
kubectl kustomize "https://github.com/nginxinc/nginx-gateway-fabric/config/crd/gateway-api/standard?ref=v1.4.0" | kubectl apply -f -
kubectl apply -f https://raw.githubusercontent.com/nginxinc/nginx-gateway-fabric/v1.4.0/deploy/crds.yaml
```

### Implantando o NGINX Gateway

```bash
kubectl apply -f https://raw.githubusercontent.com/nginxinc/nginx-gateway-fabric/v1.4.0/deploy/nodeport/deploy.yaml
```

### Configurando o Gateway e o Serviço

#### Criando o Gateway

- [`gateway.yaml`](./gateway.yaml)

```bash
kubectl apply -f gateway.yaml
```

#### Criando o Serviço

- [`gateway-service.yaml`](./gateway-service.yaml)

```bash
kubectl apply -f gateway-service.yaml
```

### Verificando a instalação

#### Verificando os Pods

```bash
kubectl get pods -n nginx-gateway
```

#### Testando o Gateway

```bash
curl -v http://localhost:8080
```

### Aplicações e Roteamento

#### Deployment de aplicações

- [`app1.yaml`](./app1.yaml)
- [`app2.yaml`](./app2.yaml)

```bash
kubectl apply -f app1.yaml
kubectl apply -f app2.yaml

kubectl get pods
```

#### Services para as aplicações

- [`svc1.yaml`](./svc1.yaml)
- [`svc2.yaml`](./svc2.yaml)

```bash
kubectl apply -f svc1.yaml
kubectl apply -f svc2.yaml

kubectl get svc
```

#### Configurando o HTTPRoute

- [`http_route.yaml`](./http_route.yaml)

```bash
kubectl apply -f http_route.yaml

kubectl get httproute
```

#### Testando o roteamento

```bash
curl -v http://localhost:8080/app1

curl -v http://localhost:8080/app2
```

## NGINX Gateway Fabric: Get started

### About

This is a guide for getting started with NGINX Gateway Fabric. It explains how to:

- Set up a kind (Kubernetes in Docker) cluster
- Install NGINX Gateway Fabric with NGINX
- Test NGINX Gateway Fabric with an example application

By following the steps in order, you will finish with a functional NGINX Gateway Fabric cluster.

### Setup a kind cluster

- [`nginx-kind.yaml`](./nginx-kind.yaml)

```bash
kind create cluster --config nginx-kind.yaml
```

### Install NGINX Gateway Fabric

#### Add Gateway API resources

```bash
kubectl kustomize "https://github.com/nginx/nginx-gateway-fabric/config/crd/gateway-api/standard?ref=v1.6.1" | kubectl apply -f -
```

#### Install the Helm chart

```bash
helm install ngf oci://ghcr.io/nginx/charts/nginx-gateway-fabric --create-namespace -n nginx-gateway --set service.create=false
```

#### Set up a NodePort

- [`nginx-nodeport-config.yaml`](./nginx-nodeport-config.yaml)

> ***Note:*** The highlighted nodePort values should equal the containerPort values from nginx-kind.yaml when you created the kind cluster.

```bash
kubectl apply -f nginx-nodeport-config.yaml
```

### Create an example application

> ***Note:*** The YAML code in the following sections can be found in the [cafe-example folder](https://github.com/nginx/nginx-gateway-fabric/tree/main/examples/cafe-example) of the GitHub repository.

#### Create the application resources

- [`nginx-cafe.yaml`](./nginx-cafe.yaml)

```bash
kubectl apply -f nginx-cafe.yaml
```

#### Create Gateway and HTTPRoute resources

- [`nginx-gateway.yaml`](./nginx-gateway.yaml)

```bash
kubectl apply -f nginx-gateway.yaml
```

- [`nginx-cafe-route.yaml`](./nginx-cafe-route.yaml)

```bash
kubectl apply -f nginx-cafe-route.yaml
```

#### Verify the configuration

```bash
kubectl get service --all-namespaces

kubectl describe httproutes.gateway.networking.k8s.io 

kubectl describe gateways
```

#### Test NGINX Gateway Fabric

```bash
#### --resolve on curl is required to resolve the hostname to the IP address of the kind cluster
curl --resolve cafe.0a0f122c.nip.io:8080:127.0.0.1   http://cafe.0a0f122c.nip.io:8080/coffee
curl --resolve cafe.0a0f122c.nip.io:8080:10.15.18.44 http://cafe.0a0f122c.nip.io:8080/coffee

curl http://cafe.example.com:8080/coffee
curl http://cafe.example.com:8080/tea
```

## Application routes using HTTP matching conditions

### Coffee applications

#### Deploy the Coffee applications

- [`nginx-coffee-v1v2.yaml`](./nginx-coffee-v1v2.yaml)

```bash
kubectl apply -f nginx-coffee-v1v2.yaml
```

#### Deploy the Gateway API Resources for the Coffee applications

- [`nginx-adv-gateway.yaml`](./nginx-adv-gateway.yaml)

```bash
kubectl apply -f nginx-adv-gateway.yaml
```

- [`nginx-adv-routes.yaml`](./nginx-adv-routes.yaml)

```bash
kubectl apply -f nginx-adv-routes.yaml
```

#### Send traffic to Coffee

```bash
#### --resolve on curl is required to resolve the hostname to the IP address of the kind cluster
curl --resolve cafe.0a0f122c.nip.io:8080:127.0.0.1   http://cafe.0a0f122c.nip.io:8080/coffee
curl --resolve cafe.0a0f122c.nip.io:8080:10.15.18.44 http://cafe.0a0f122c.nip.io:8080/coffee
curl http://cafe.0a0f122c.nip.io:8080/coffee

curl --resolve cafe.0a0f122c.nip.io:8080:10.15.18.44 http://cafe.0a0f122c.nip.io:8080/coffee -H "version:v2"
curl http://cafe.0a0f122c.nip.io:8080/coffee -H "version:v2"

curl --resolve cafe.0a0f122c.nip.io:8080:10.15.18.44 http://cafe.0a0f122c.nip.io:8080/coffee?TEST=v2
curl http://cafe.0a0f122c.nip.io:8080/coffee?TEST=v2
```

### Tea applications

#### Deploy the Tea applications

- [`nginx-tea-v1post.yaml`](./nginx-tea-v1post.yaml)

```bash
kubectl apply -f nginx-tea-v1post.yaml
```

#### Deploy the HTTPRoute for the Tea services

- [`nginx-adv-tea-routes.yaml`](./nginx-adv-tea-routes.yaml)

```bash
kubectl apply -f nginx-adv-tea-routes.yaml
```

#### Send traffic to Tea

```bash
#### --resolve on curl is required to resolve the hostname to the IP address of the kind cluster

curl --resolve cafe.0a0f122c.nip.io:8080:127.0.0.1   http://cafe.0a0f122c.nip.io:8080/tea
curl --resolve cafe.0a0f122c.nip.io:8080:10.15.18.44 http://cafe.0a0f122c.nip.io:8080/tea
curl http://cafe.0a0f122c.nip.io:8080/tea

curl --resolve cafe.0a0f122c.nip.io:8080:10.15.18.44 http://cafe.0a0f122c.nip.io:8080/tea -X POST
curl http://cafe.0a0f122c.nip.io:8080/tea -X POST
```

## That's all

...folks!!!
