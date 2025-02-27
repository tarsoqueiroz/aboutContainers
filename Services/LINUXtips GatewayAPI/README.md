# Descomplicando Gateway API no Kubernetes

## Sobre

Neste artigo completo da LINUXtips, escrito por Jeferson Fernando, você aprenderá a montar um cluster Kubernetes utilizando o KIND (Kubernetes IN Docker) e a configurar o NGINX Gateway Fabric para gerenciar eficientemente o tráfego das suas aplicações. Abordaremos desde a instalação dos pré-requisitos essenciais, como Docker, kubectl e KIND, até configurações avançadas de roteamento utilizando HTTPRoute, incluindo balanceamento de carga, redirecionamentos, rate limiting e segurança TLS. Além disso, você descobrirá como implantar aplicações, testar o roteamento, escalar serviços e monitorar logs para garantir um ambiente Kubernetes robusto, seguro e escalável. Este artigo da LINUXtips.io é ideal para desenvolvedores e administradores que desejam otimizar a gestão de tráfego em seus clusters Kubernetes de maneira eficiente e segura.

## Sources

- [Descomplicando Gateway API no Kubernetes: Parte 1](https://linuxtips.io/descomplicando-gateway-api-no-kubernetes/)
- [NGINX Gateway Fabric: Github](https://github.com/nginx/nginx-gateway-fabric)
- [NGINX Gateway Fabric: Get started](https://docs.nginx.com/nginx-gateway-fabric/get-started/)

## Pre-requisitos

- **Docker:** Fundamental para a criação de contêineres. Instale o Docker.
- **kubectl:** Ferramenta de linha de comando para interagir com Kubernetes. Instale o kubectl.
- **KIND:** Utilizado para criar clusters Kubernetes dentro de contêineres Docker. Instale o KIND.

## Criando o Cluster com o KIND

- [`kind.yaml`](./kind.yaml)

```bash
kind create cluster --name strigus --config kind.yaml
```

## Instalando o NGINX Gateway Fabric

Aplicando as CRDs:

```bash
kubectl kustomize "https://github.com/nginxinc/nginx-gateway-fabric/config/crd/gateway-api/standard?ref=v1.4.0" | kubectl apply -f -
kubectl apply -f https://raw.githubusercontent.com/nginxinc/nginx-gateway-fabric/v1.4.0/deploy/crds.yaml
```

## Implantando o NGINX Gateway

```bash
kubectl apply -f https://raw.githubusercontent.com/nginxinc/nginx-gateway-fabric/v1.4.0/deploy/nodeport/deploy.yaml
```

## Configurando o Gateway e o Serviço

### Criando o Gateway

- [`gateway.yaml`](./gateway.yaml)

```bash
kubectl apply -f gateway.yaml
```

### Criando o Serviço

- [`gateway-service.yaml`](./gateway-service.yaml)

```bash
kubectl apply -f gateway-service.yaml
```

## Verificando a instalação

### Verificando os Pods

```bash
kubectl get pods -n nginx-gateway
```

### Testando o Gateway

```bash
curl -v http://localhost:8080
```

## Aplicações e Roteamento

### Deployment de aplicações

- [`app1.yaml`](./app1.yaml)
- [`app2.yaml`](./app2.yaml)

```bash
kubectl apply -f app1.yaml
kubectl apply -f app2.yaml

kubectl get pods
```

### Services para as aplicações

- [`svc1.yaml`](./svc1.yaml)
- [`svc2.yaml`](./svc2.yaml)

```bash
kubectl apply -f svc1.yaml
kubectl apply -f svc2.yaml

kubectl get svc
```

### Configurando o HTTPRoute

- [`http_route.yaml`](./http_route.yaml)

```bash
kubectl apply -f http_route.yaml

kubectl get httproute
```

### Testando o roteamento

```bash
curl -v http://localhost:8080/app1

curl -v http://localhost:8080/app2
```

## That's all

...folks!
