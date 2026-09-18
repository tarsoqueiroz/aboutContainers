# Cluster Kind (Kubernetes IN Docker) com Cilium como CNI e API Gateway

## Sumário

- [Cluster Kind (Kubernetes IN Docker) com Cilium como CNI e API Gateway](#cluster-kind-kubernetes-in-docker-com-cilium-como-cni-e-api-gateway)
  - [Sumário](#sumário)
  - [1. Visão geral da arquitetura](#1-visão-geral-da-arquitetura)
  - [2. Pré-requisitos](#2-pré-requisitos)
    - [Validação da etapa](#validação-da-etapa)
  - [3. Estrutura de diretórios](#3-estrutura-de-diretórios)
    - [Validação da etapa](#validação-da-etapa-1)
  - [4. Definição do cluster (`kind-config.yaml`)](#4-definição-do-cluster-kind-configyaml)
    - [Validação da etapa](#validação-da-etapa-2)
  - [5. Criação do cluster](#5-criação-do-cluster)
    - [Validação da etapa](#validação-da-etapa-3)
  - [6. Aplicação dos limites de CPU/Memória por nó](#6-aplicação-dos-limites-de-cpumemória-por-nó)
    - [Validação da etapa](#validação-da-etapa-4)
  - [7. Instalação dos CRDs do Gateway API](#7-instalação-dos-crds-do-gateway-api)
    - [Validação da etapa](#validação-da-etapa-5)
  - [8. Instalação do Cilium via Helm](#8-instalação-do-cilium-via-helm)
    - [Validação da etapa](#validação-da-etapa-6)
  - [9. Certificado TLS wildcard self-signed](#9-certificado-tls-wildcard-self-signed)
    - [Validação da etapa](#validação-da-etapa-7)
  - [10. Gateway API — Gateway (porta 80/443)](#10-gateway-api--gateway-porta-80443)
    - [Validação da etapa](#validação-da-etapa-8)
  - [11. Publicando App, API e serviço gRPC](#11-publicando-app-api-e-serviço-grpc)
    - [Validação da etapa](#validação-da-etapa-9)
  - [12. Testes de acesso pela rede local](#12-testes-de-acesso-pela-rede-local)
  - [13. Observabilidade e troubleshooting](#13-observabilidade-e-troubleshooting)
    - [Problemas comuns](#problemas-comuns)
  - [14. Cleanup](#14-cleanup)
  - [15. Anexos — arquivos completos](#15-anexos--arquivos-completos)

---

## 1. Visão geral da arquitetura

| Item | Valor |
|---|---|
| Nós | 1 control-plane (CP) + 3 workers |
| Limite CP | cpu=1000m / memory=1024Mi |
| Limite por Worker | cpu=2000m / memory=4096Mi |
| CNI | Cilium (substitui também o kube-proxy) |
| Ingress/API Gateway | Cilium Gateway API (Envoy embarcado, modo hostNetwork) |
| Portas expostas ao host | 80 (HTTP) e 443 (HTTPS/gRPC) |
| IP do host na rede local | `10.15.18.44` |
| Sufixo de domínio | `*.0a0f122c.nip.io` |
| Kubernetes | v1.33.1 (`kindest/node:v1.33.1`) |
| Cilium | 1.20.1 |
| Gateway API | v1.6.1 |

```text
                      Rede local (10.15.18.0/24)
                                │
                                │  :80 / :443
                                ▼
                    Host Docker (10.15.18.44)
                                │  hostPort→containerPort
                                ▼
                 ┌────────────────────────────┐
                 │  kind-cilium-control-plane │  ◄── Envoy (Cilium Gateway API, hostNetwork)
                 │   cpu=1000m / mem=1024Mi   │
                 └────────────────────────────┘
                                │
        ┌───────────────────────┼───────────────────────┐
        ▼                       ▼                       ▼
 kind-cilium-worker      kind-cilium-worker2      kind-cilium-worker3
 cpu=2000m/mem=4096Mi    cpu=2000m/mem=4096Mi    cpu=2000m/mem=4096Mi
  (app / API / gRPC)      (app / API / gRPC)      (app / API / gRPC)
```

**Por que Cilium também como Gateway?** 

O Cilium implementa a *Gateway API* nativamente (sem precisar de um Ingress Controller separado como o NGINX). O Envoy embarcado no Cilium roda em `hostNetwork` apenas no nó control-plane (único nó com as portas 80/443 mapeadas para o host), recebendo o tráfego HTTP, HTTPS e gRPC e roteando via `HTTPRoute` / `GRPCRoute` para os serviços internos.

> **Nota sobre limites de recurso:**
> 
> O Kind não possui um campo nativo em `kind-config.yaml` para limitar CPU/memória por nó — cada nó Kind é, na prática, um container Docker. Os limites são aplicados via `docker update --cpus --memory` logo após a criação do cluster (Seção 6). O `kubelet`/cAdvisor dentro do nó lê o cgroup do próprio container, então `kubectl describe node` deve refletir a Capacity/Allocatable corretas — validaremos isso na própria seção.

---

## 2. Pré-requisitos

| Ferramenta | Uso |
|---|---|
| Docker | runtime dos nós Kind |
| `kind` | criação do cluster |
| `kubectl` | administração do cluster |
| `helm` | instalação do Cilium |
| `cilium-cli` | status/health check do Cilium |
| `openssl` | geração do certificado self-signed |

### Validação da etapa

```bash
docker version --format '{{.Server.Version}}'
kind version
kubectl version --client
helm version --short
openssl version
```

Instalação do `cilium-cli` (Linux amd64/arm64):

```bash
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)

CLI_ARCH=amd64

if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}

sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum

sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin

rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}

cilium version --client
```

---

## 3. Estrutura de diretórios

```
cloudKind/
├── README.md
├── manifestos/
│   ├── kind-config.yaml
│   ├── cilium-values.yaml
│   ├── gateway.yaml
│   ├── httproute-app.yaml
│   ├── httproute-api.yaml
│   └── grpcroute-service.yaml
├── certs/
│   ├── wildcard.key
│   └── wildcard.crt
└── scripts/
    ├── set-node-limits.sh
    └── gen-wildcard-cert.sh
```

### Validação da etapa

Dentro do diretório `cloudKind` execute:

```bash
find . -maxdepth 3 -type d
```

---

## 4. Definição do cluster (`kind-config.yaml`)

Pontos-chave:

- `disableDefaultCNI: true` → o `kindnet` não é instalado; o Cilium assume o CNI.
- `kubeProxyMode: none` → o `kube-proxy` não é instalado; o Cilium assume o *kube-proxy replacement* (eBPF).
- `extraPortMappings` **apenas no control-plane** → mapeia 80/443 do host Docker para o container do CP (onde o Envoy do Gateway API vai escutar em modo `hostNetwork`).
- Label `ingress-ready=true` no CP → usada depois para restringir onde o Envoy do Gateway API roda (Seção 8).
- `nodeImage` fixado em `v1.33.1` com digest, para reprodutibilidade e para permitir ensaiar upgrades futuros de versão.

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: kind-cilium
networking:
  disableDefaultCNI: true   # Cilium substitui o kindnet
  kubeProxyMode: "none"     # Cilium substitui o kube-proxy (eBPF)
nodes:
  - role: control-plane
    image: kindest/node:v1.33.1@sha256:14ffd6ee8a3daa20cc934ba786626b181e1797268c5465f2c299a7cf54494c77
    kubeadmConfigPatches:
      - |
        kind: InitConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            node-labels: "ingress-ready=true"
    extraPortMappings:
      - containerPort: 80
        hostPort: 80
        listenAddress: "0.0.0.0"
        protocol: TCP
      - containerPort: 443
        hostPort: 443
        listenAddress: "0.0.0.0"
        protocol: TCP
  - role: worker
    image: kindest/node:v1.33.1@sha256:14ffd6ee8a3daa20cc934ba786626b181e1797268c5465f2c299a7cf54494c77
  - role: worker
    image: kindest/node:v1.33.1@sha256:14ffd6ee8a3daa20cc934ba786626b181e1797268c5465f2c299a7cf54494c77
  - role: worker
    image: kindest/node:v1.33.1@sha256:14ffd6ee8a3daa20cc934ba786626b181e1797268c5465f2c299a7cf54494c77
```

> `listenAddress: "0.0.0.0"` garante que o host aceite conexões vindas da rede local (`10.15.18.44`), e não apenas de `127.0.0.1`.

### Validação da etapa

```bash
# valida sintaticamente o YAML antes de criar o cluster
kind create cluster --config ./manifestos/kind-config.yaml --name kind-cilium --dry-run 2>/dev/null || \
  echo "kind não suporta --dry-run nativo; validar com um linter YAML:"

python3 -c "import yaml,sys; yaml.safe_load(open('./manifestos/kind-config.yaml')); print('YAML válido')"
```

---

## 5. Criação do cluster

```bash
kind create cluster --config kind-config.yaml
```

Como o CNI e o kube-proxy estão desabilitados, os nós ficarão em `NotReady` — **isso é esperado** até instalarmos o Cilium (Seção 8).

### Validação da etapa

```bash
kind get clusters
# esperado: kind-cilium

kubectl cluster-info --context kind-kind-cilium

kubectl get nodes -o wide
# esperado: 4 nós (1 control-plane + 3 worker), STATUS = NotReady

docker ps --filter "label=io.x-k8s.kind.cluster=kind-cilium" \
  --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
# esperado: kind-cilium-control-plane com 0.0.0.0:80->80/tcp e 0.0.0.0:443->443/tcp
```

---

## 6. Aplicação dos limites de CPU/Memória por nó

Script `scripts/set-node-limits.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

CLUSTER="kind-cilium"

# Control-plane: cpu=1000m (1 vCPU) / memory=1024Mi
docker update \
  --cpus="1" \
  --memory="1024m" --memory-swap="1024m" \
  "${CLUSTER}-control-plane"

# Workers: cpu=2000m (2 vCPU) / memory=4096Mi cada
for node in $(docker ps --filter "label=io.x-k8s.kind.cluster=${CLUSTER}" \
              --format "{{.Names}}" | grep worker); do
  docker update \
    --cpus="2" \
    --memory="4096m" --memory-swap="4096m" \
    "${node}"
done

echo "Limites aplicados. Reiniciando containers para que o kubelet/cAdvisor releia o cgroup..."
docker restart "${CLUSTER}-control-plane" $(docker ps --filter "label=io.x-k8s.kind.cluster=${CLUSTER}" --format "{{.Names}}" | grep worker)
```

```bash
chmod +x scripts/set-node-limits.sh
./scripts/set-node-limits.sh
```

> **Por que reiniciar o container?** O `kubelet` calcula a *Capacity* do nó lendo o cgroup no momento em que sobe. Ajustar o limite via `docker update` depois que o kubelet já está rodando pode não refletir imediatamente em `kubectl describe node`; reiniciar o container garante que o kubelet suba já enxergando o novo limite.

### Validação da etapa

```bash
# Confere o limite aplicado no Docker
for c in kind-cilium-control-plane kind-cilium-worker kind-cilium-worker2 kind-cilium-worker3; do
  echo "== $c =="
  docker inspect "$c" --format 'CPUs(NanoCPUs)={{.HostConfig.NanoCpus}}  Memory={{.HostConfig.Memory}}'
done

# Aguarda os nós voltarem (Cilium ainda não instalado -> continuam NotReady, mas devem responder)
kubectl wait --for=condition=Ready=false node --all --timeout=60s || true

# Confere Capacity/Allocatable refletidos no Kubernetes (após instalar o Cilium na Seção 8)
kubectl describe node kind-cilium-control-plane | grep -A6 "Capacity:"
kubectl describe node kind-cilium-worker | grep -A6 "Capacity:"
```

Esperado (aproximado, pode variar por overhead do SO dentro do container):
- `kind-cilium-control-plane` → `cpu: 1`, `memory: ~1Gi`
- `kind-cilium-worker*` → `cpu: 2`, `memory: ~4Gi`

---

## 7. Instalação dos CRDs do Gateway API

O Cilium 1.20 implementa a **Gateway API v1.6.1**. Instalamos os CRDs obrigatórios (Standard channel):

```bash
GWAPI_VERSION=v1.6.1
for crd in gatewayclasses gateways httproutes referencegrants grpcroutes backendtlspolicies tlsroutes; do
  kubectl apply --server-side -f \
    "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/${GWAPI_VERSION}/config/crd/standard/gateway.networking.k8s.io_${crd}.yaml"
done
```

### Validação da etapa

```bash
kubectl get crds | grep gateway.networking.k8s.io
```
Esperado: `gatewayclasses`, `gateways`, `httproutes`, `referencegrants`, `grpcroutes`, `backendtlspolicies`, `tlsroutes`.

---

## 8. Instalação do Cilium via Helm

Como o `kube-proxy` foi desabilitado, o Cilium precisa saber **diretamente** o endereço do kube-apiserver (não pode resolver o Service `kubernetes.default` sem kube-proxy). Obtemos o IP interno do container do control-plane:

```bash
API_SERVER_IP=$(docker inspect kind-cilium-control-plane \
  --format '{{ .NetworkSettings.Networks.kind.IPAddress }}')
echo "$API_SERVER_IP"
```

`cilium-values.yaml`:

```yaml
kubeProxyReplacement: true
k8sServiceHost: "__API_SERVER_IP__"   # substituído dinamicamente abaixo
k8sServicePort: 6443

ipam:
  mode: kubernetes

l7Proxy: true

envoy:
  enabled: true
  securityContext:
    capabilities:
      keepCapNetBindService: true
      # IMPORTANTE: esta lista SUBSTITUI a lista padrão de capabilities do
      # container cilium-envoy — nunca a reduza para conter só NET_BIND_SERVICE,
      # ou o Envoy falha ao iniciar em todos os nós (ver Seção 13).
      # NET_ADMIN + BPF + PERFMON cobrem kernels >= 5.8 com containerd >= 1.5 / CRI-O >= 1.22
      # (troque BPF/PERFMON por SYS_ADMIN em kernels mais antigos).
      envoy:
        - NET_ADMIN
        - PERFMON
        - BPF
        - NET_BIND_SERVICE

gatewayAPI:
  enabled: true
  hostNetwork:
    enabled: true
    nodes:
      matchLabels:
        ingress-ready: "true"   # só roda o Envoy do Gateway no control-plane

hubble:
  enabled: true
  relay:
    enabled: true
  ui:
    enabled: true

operator:
  replicas: 1
```

Instalação:

```bash
helm repo add cilium https://helm.cilium.io/
helm repo update

API_SERVER_IP=$(docker inspect kind-cilium-control-plane \
  --format '{{ .NetworkSettings.Networks.kind.IPAddress }}')

helm install cilium cilium/cilium --version 1.20.1 \
  --namespace kube-system \
  -f cilium-values.yaml \
  --set k8sServiceHost="${API_SERVER_IP}" \
  --set k8sServicePort=6443
```

### Validação da etapa

```bash
cilium status --wait

kubectl get pods -n kube-system -l k8s-app=cilium
kubectl get pods -n kube-system -l name=cilium-operator

kubectl get nodes -o wide
# esperado: todos os 4 nós em STATUS = Ready

kubectl get gatewayclass
# esperado: gatewayclass "cilium" com ACCEPTED=True

cilium connectivity test --test '!datapath-tunnel,!pod-to-service-egress-gw' # opcional, teste mais completo
```

---

## 9. Certificado TLS wildcard self-signed

`scripts/gen-wildcard-cert.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

DOMAIN="0a0f122c.nip.io"
OUT_DIR="./certs"
mkdir -p "$OUT_DIR"

openssl req -x509 -nodes -newkey rsa:2048 \
  -keyout "${OUT_DIR}/wildcard.key" \
  -out "${OUT_DIR}/wildcard.crt" \
  -days 365 \
  -subj "/CN=*.${DOMAIN}/O=homelab-dev" \
  -addext "subjectAltName=DNS:*.${DOMAIN},DNS:${DOMAIN}"

kubectl create namespace network --dry-run=client -o yaml | kubectl apply -f -

kubectl -n network create secret tls wildcard-tls \
  --cert="${OUT_DIR}/wildcard.crt" \
  --key="${OUT_DIR}/wildcard.key" \
  --dry-run=client -o yaml | kubectl apply -f -
```

```bash
chmod +x scripts/gen-wildcard-cert.sh
./scripts/gen-wildcard-cert.sh
```

### Validação da etapa

```bash
openssl x509 -in certs/wildcard.crt -noout -subject -ext subjectAltName
kubectl -n network get secret wildcard-tls
```

---

## 10. Gateway API — Gateway (porta 80/443)

`manifestos/gateway.yaml`:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: cilium-gateway
  namespace: network
spec:
  gatewayClassName: cilium
  listeners:
    - name: http
      protocol: HTTP
      port: 80
      allowedRoutes:
        namespaces:
          from: All
    - name: https
      protocol: HTTPS
      port: 443
      tls:
        mode: Terminate
        certificateRefs:
          - name: wildcard-tls
      allowedRoutes:
        namespaces:
          from: All
```

```bash
kubectl apply -f manifestos/gateway.yaml
```

### Validação da etapa

```bash
kubectl get gateway -n network
# esperado: CLASS=cilium  PROGRAMMED=True

kubectl describe gateway cilium-gateway -n network
# checar: Accepted=True, Programmed=True, ResolvedRefs=True nos listeners http e https
```

---

## 11. Publicando App, API e serviço gRPC

Deploys de exemplo (substitua pelas imagens reais das suas aplicações).

`manifestos/httproute-app.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo-app
  namespace: network
spec:
  replicas: 2
  selector:
    matchLabels: { app: demo-app }
  template:
    metadata:
      labels: { app: demo-app }
    spec:
      containers:
        - name: demo-app
          image: nginxdemos/hello:plain-text
          ports: [{ containerPort: 80 }]
---
apiVersion: v1
kind: Service
metadata:
  name: demo-app
  namespace: network
spec:
  selector: { app: demo-app }
  ports: [{ port: 80, targetPort: 80 }]
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: demo-app
  namespace: network
spec:
  parentRefs:
    - name: cilium-gateway
  hostnames:
    - "app.0a0f122c.nip.io"
  rules:
    - backendRefs:
        - name: demo-app
          port: 80
```

`manifestos/httproute-api.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo-api
  namespace: network
spec:
  replicas: 2
  selector:
    matchLabels: { app: demo-api }
  template:
    metadata:
      labels: { app: demo-api }
    spec:
      containers:
        - name: demo-api
          image: kennethreitz/httpbin
          ports: [{ containerPort: 80 }]
---
apiVersion: v1
kind: Service
metadata:
  name: demo-api
  namespace: network
spec:
  selector: { app: demo-api }
  ports: [{ port: 80, targetPort: 80 }]
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: demo-api
  namespace: network
spec:
  parentRefs:
    - name: cilium-gateway
  hostnames:
    - "api.0a0f122c.nip.io"
  rules:
    - backendRefs:
        - name: demo-api
          port: 80
```

`manifestos/grpcroute-service.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo-grpc
  namespace: network
spec:
  replicas: 2
  selector:
    matchLabels: { app: demo-grpc }
  template:
    metadata:
      labels: { app: demo-grpc }
    spec:
      containers:
        - name: grpcbin
          image: moul/grpcbin
          ports: [{ containerPort: 9000 }]
---
apiVersion: v1
kind: Service
metadata:
  name: demo-grpc
  namespace: network
spec:
  selector: { app: demo-grpc }
  ports: [{ port: 9000, targetPort: 9000, appProtocol: kubernetes.io/h2c }]
---
apiVersion: gateway.networking.k8s.io/v1
kind: GRPCRoute
metadata:
  name: demo-grpc
  namespace: network
spec:
  parentRefs:
    - name: cilium-gateway
      sectionName: https
  hostnames:
    - "grpc.0a0f122c.nip.io"
  rules:
    - backendRefs:
        - name: demo-grpc
          port: 9000
```

```bash
kubectl apply -f manifestos/httproute-app.yaml
kubectl apply -f manifestos/httproute-api.yaml
kubectl apply -f manifestos/grpcroute-service.yaml
```

### Validação da etapa

```bash
kubectl get pods -n network -o wide
kubectl get httproute,grpcroute -n network

kubectl describe httproute demo-app -n network | grep -A3 Conditions
kubectl describe httproute demo-api -n network | grep -A3 Conditions
kubectl describe grpcroute demo-grpc -n network | grep -A3 Conditions
# esperado em todas: Accepted=True, ResolvedRefs=True
```

---

## 12. Testes de acesso pela rede local

Garanta que `app.0a0f122c.nip.io`, `api.0a0f122c.nip.io` e `grpc.0a0f122c.nip.io` resolvem para `10.15.18.44` (o sufixo `nip.io` já cuida da resolução por design; confirme com `dig`/`nslookup` antes de testar).

```bash
dig +short app.0a0f122c.nip.io
dig +short api.0a0f122c.nip.io
dig +short grpc.0a0f122c.nip.io
```

Teste HTTP (porta 80, redirecionamento opcional para HTTPS — aqui testamos direto):

```bash
curl -v http://app.0a0f122c.nip.io/
```

Teste HTTPS (porta 443, certificado self-signed — usar `-k` para não validar a CA):

```bash
curl -vk https://app.0a0f122c.nip.io/
curl -vk https://api.0a0f122c.nip.io/get
```

Teste gRPC (requer `grpcurl`):

```bash
grpcurl -insecure grpc.0a0f122c.nip.io:443 list
grpcurl -insecure grpc.0a0f122c.nip.io:443 grpcbin.GRPCBin/Empty
```

**A partir de outra máquina na rede local** (não no host Docker), repita os mesmos comandos — eles devem funcionar da mesma forma, pois o tráfego chega em `10.15.18.44:80/443` e é encaminhado pelo Docker até o container do control-plane.

---

## 13. Observabilidade e troubleshooting

```bash
# Visão geral do Cilium
cilium status

# Hubble UI (porta-forward local)
cilium hubble ui

# Fluxos em tempo real relacionados ao Gateway
hubble observe --namespace network -f

# Logs do operador (útil para erros de CRD/Gateway)
kubectl -n kube-system logs deploy/cilium-operator | grep -i gateway
```

### Problemas comuns

| Sintoma | Causa provável | Ação |
|---|---|---|
| Nós ficam `NotReady` após `kind create cluster` | Esperado — CNI ainda não instalado | Prosseguir para a instalação do Cilium |
| `cilium status` trava em "waiting for k8s-apiserver" | `k8sServiceHost`/`k8sServicePort` incorretos | Reconferir IP do container do CP (`docker inspect`) |
| `curl` para 80/443 dá "connection refused" no host | Porta não mapeada, ou Envoy do Gateway não subiu no CP | `docker ps` (checar mapeamento) e `kubectl -n kube-system get pods -l k8s-app=cilium -o wide` |
| Gateway `Programmed=False` | CRDs do Gateway API ausentes ou `gatewayAPI.enabled=false` | Reaplicar CRDs (Seção 7) e `helm upgrade` com `--reuse-values` |
| `HTTPRoute`/`GRPCRoute` com `ResolvedRefs=False` | Service backend não existe ou porta errada | `kubectl describe` na route e conferir `Service` |

---

## 14. Cleanup

```bash
kind delete cluster --name kind-cilium
```

---

## 15. Anexos — arquivos completos

Os arquivos completos (`kind-config.yaml`, `cilium-values.yaml`, scripts e manifestos) estão nos respectivos caminhos descritos na Seção 3, prontos para uso — basta copiar a estrutura de diretórios e seguir as seções 4 a 12 em ordem.
