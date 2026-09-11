# cloudKind: Cloud com Kind

## Configuração e Arquitetura

Para atender a todos os requisitos solicitados — incluindo **Cilium sem Kube-Proxy**, **isolamento de workloads (Node Affinity/Tolerations)**, **API Gateway**, **limites de hardware nos nós Docker** e **Inbound pelo Control-Plane** —, vamos estruturar a solução em etapas sequenciais.

- **Topologia**: 1 Control-Plane e 3 Workers.
- **Cilium CNI**: O CNI padrão do Kind (kindnet) e o kube-proxy serão desativados na criação do cluster para que o Cilium assuma o roteamento via eBPF (substituindo o Kube-Proxy).
- **Limites de Hardware**: Configurados via limites de CPU e memória nas definições dos nós Docker.
- **Isolamento de Workloads**:
  - O nó **Control-Plane** aceitará o Gateway/Ingress e componentes de controle.
  - Os **Workers** receberão Taints de **workload=app:NoSchedule** para garantir que aplicações rodem apenas neles.
- Gateway & Rotas: Cilium Ingress / Gateway API com suporte ao domínio wildcard ***.0a0f122c.nip.io**.

## Criação do Cluster Kind (1 Control-Plane + 3 Workers)

Nesta etapa, vamos criar a definição do cluster com:

- **Desativação do CNI padrão (`kindnet`)** para podermos instalar o Cilium.
- **Desativação do `kube-proxy`** para o Cilium assumir o roteamento nativo via eBPF.
- **Mapeamento de portas (HostPort)** no nó `control-plane` (80, 443, 8080, 8443, 9090).
- **Taints nos Workers (`workload=app:NoSchedule`)** para isolar o plano de controle das aplicações.

O arquivo [`kind-config.yaml`](./manifestos/kind-config.yaml) contém as configurações necessárias para atender as definições acima.

Execute o seguinte comando para criar o cluster:

```bash
kind create cluster --name lab-cluster --config kind-config.yaml
```

Execute o comando a seguir para verificar se os 4 nós foram criados:

```bash
# Teste e Validação da Etapa
kubectl get nodes -o wide
```

Resultado esperado:

- 1 nó `control-plane` e 3 nós `worker`
- Os nós estarão com STATUS `NotReady` pois ainda não instalamos o plugin de rede (Cilium)

Validar as reservas de Hardware nos nós:

```bash
kubectl describe nodes
```

## Instalação do Cilium CNI (Substituindo Kube-Proxy) + Gateway API

Agora vamos instalar o ecossistema do Cilium no cluster, ativando a substituição completa do Kube-Proxy via eBPF e preparando o suporte ao Gateway API.

Antes de subir o Cilium com suporte a Gateway API, precisamos registrar as APIs padrão de roteamento da comunidade Kubernetes:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/standard/gateway.networking.k8s.io_gatewayclasses.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/standard/gateway.networking.k8s.io_gateways.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/standard/gateway.networking.k8s.io_httproutes.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/standard/gateway.networking.k8s.io_referencegrants.yaml
```

Instalar o Cilium CLI (caso ainda não tenha na máquina)

```bash
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name "https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz"
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz
```

Deploy do Cilium no Cluster executando o comando que segue para instalar o Cilium desativando o Kube-Proxy e ativando o Gateway API:

```bash
cilium install \
  --set kubeProxyReplacement=true \
  --set k8sServiceHost=lab-cluster-control-plane \
  --set k8sServicePort=6443 \
  --set gatewayAPI.enabled=true \
  --set operator.replicas=1
```

Aguarde alguns instantes e rode os comandos de validação:

```bash
cilium status --wait
```

Verificar se os nós mudaram para o status Ready:

```bash
kubectl get nodes -o wide
```

## Configuração do Cilium Gateway API (Portas do Control-Plane)

Nesta etapa, vamos provisionar o **Gateway** do Cilium para escutar nas portas mapeadas no nó `control-plane` (`80, 443, 8080, 8443, 9090`) onde as portas do host estão mapeadas pelo Docker, e direcionar o tráfego externo para o cluster. Incluiremos a toleration necessária no manifesto que está no arquivo [`cilium-gateway.yaml`](./manifestos/cilium-gateway.yaml).

Gerar certificado TLS Autoassinado para suportar HTTPS (443 e 8443).

Para liberar as listeners HTTPS sem erros de referência de certificado, crie um certificado de teste rápido para o domínio *.0a0f122c.nip.io:

```bash
# Gera chave e certificado para o domínio wildcard .0a0f122c.nip.io
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout tls.key -out tls.crt \
  -subj "/CN=*.0a0f122c.nip.io/O=LabGateway"

# Armazena o certificado no Kubernetes Secret esperado pelo Gateway
kubectl create secret tls gateway-tls-cert \
  --key=tls.key \
  --cert=tls.crt \
  -n kube-system

# Remove os arquivos locais temporários
rm tls.key tls.crt
```

Aplicar a definição do Gateway: 

```bash
kubectl apply -f cilium-gateway.yaml
```

Execute o comando a seguir para checar se o Cilium provisionou o recurso de Gateway:

```bash
kubectl get gateway -n kube-system
```

O status `PROGRAMMED: Unknown` indica que o Cilium Operator não conseguiu atribuir um IP/LoadBalancer padrão ao Gateway porque não instalamos o MetalLB nem habilitamos a reconciliação automática de NodePort/HostNetwork no Cilium.

Para rodar em um **cluster Kind com IP único**, o Cilium Gateway precisa saber que deve rodar no modo **NodePort** ou **HostNetwork** usando as portas que mapeamos no container do Control-Plane no Passo 1.

> **Solução**: Habilitar NodePort / HostNetwork no Cilium Gateway

Atualizar a instalação do Cilium para habilitar NodePort nos Gateways.

Rode a atualização da instalação do Cilium adicionando as flags para o Ingress e Gateway API trabalharem com as portas do Nó (NodePort):

```bash
cilium install \
  --set kubeProxyReplacement=true \
  --set k8sServiceHost=lab-cluster-control-plane \
  --set k8sServicePort=6443 \
  --set gatewayAPI.enabled=true \
  --set gatewayAPI.enableNodePort=true \
  --set operator.replicas=1
```


## 

```bash
kubectl label nodes lab-cluster-worker node-role.kubernetes.io/worker=worker
kubectl label nodes lab-cluster-worker2 node-role.kubernetes.io/worker=worker
kubectl label nodes lab-cluster-worker3 node-role.kubernetes.io/worker=worker

kubectl get nodes -o wide

kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.0/standard-install.yaml

kubectl get crd | grep gateway.networking.k8s.io

helm repo add cilium https://helm.cilium.io/
helm repo update

helm install cilium cilium/cilium \
   --namespace kube-system \
   --set kubeProxyReplacement=true  \
   --set k8sServiceHost=lab-cluster-control-plane \
   --set k8sServicePort=6443 \
   --set gatewayAPI.enabled=true \
   --set cgroup.autoMount.enabled=true \
   --set cgroup.hostRoot=/sys/fs/cgroup \
   --set ipam.mode=kubernetes \
   --set operator.replicas=1 \
   --set "operator.tolerations[0].operator=Exists" \
   --set "tolerations[0].operator=Exists"

kubectl get pods -n kube-system -o wide

kubectl get nodes -o wide

cilium status
```

## 




## 

