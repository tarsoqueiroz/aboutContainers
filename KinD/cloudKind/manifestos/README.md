# K8s cluster com Kind

## Prerequisitos

.

## Visão Geral das Etapas

| Etapa | Descrição | Pontos de Verificação Principais |
| :---- | :-------- | :------------------------------- |
| 1. Pré-requisitos       | Verificar Docker, kubectl, Helm e Cilium CLI.                | Comandos de versão executam sem erro. |
| 2. Configuração do Kind | Criar o arquivo `kind-lab.yaml` com todas as especificações. | O arquivo YAML está sintaticamente correto. |
| 3. Criação do Cluster   | Aplicar a configuração e criar o cluster kind-lab.           | `kubectl get nodes` mostra os 4 nós. |
| 4. Instalação do Cilium | Instalar o Cilium com kube-proxy replacement e Gateway API.  | `cilium status --wait` retorna OK. |
| 5. Verificação Final    | Validar a conectividade e o roteamento L7.                   | Teste de conectividade e Gateway API funcional. |

## Etapa 1: Pré-requisitos e Ferramentas

Nesta etapa, vamos garantir que seu host (`10.15.20.25`) tenha todas as ferramentas necessárias para criar e gerenciar o cluster Kind. O objetivo é ter um ambiente base funcional antes de partir para a configuração do cluster.

### Docker (Runtime de Containers)

O Kind usa contêineres Docker como "nós" do cluster Kubernetes. Portanto, o Docker precisa estar instalado e funcionando.

**Instalação (para distribuições baseadas em Debian/Ubuntu)**:

O método recomendado é instalar a partir do repositório oficial do Docker. O processo envolve adicionar a chave GPG e o repositório, e então instalar os pacotes

```bash
# 1. Remover pacotes conflitantes (se existirem)
sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-doc docker-buildx podman-docker containerd runc | cut -f1)

# 2. Adicionar a chave GPG oficial do Docker
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# 3. Adicionar o repositório do Docker
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

# 4. Instalar o Docker Engine
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

> **Nota**: Se você usa outra distribuição Linux (como RHEL/CentOS, Fedora), consulte a documentação oficial do Docker para os comandos específicos do seu gerenciador de pacotes.

**Ponto de Verificação**:

Após a instalação, execute o comando abaixo. Ele deve baixar uma imagem de teste e imprimir uma mensagem de confirmação.

```bash
sudo docker run hello-world
```

**Documentação Oficial**: [Install Docker Engine](https://docs.docker.com/engine/install/).

### `kubectl` (CLI do Kubernetes)

O `kubectl` é a ferramenta de linha de comando que usaremos para interagir com o cluster Kind.

**Instalação (método direto via `curl`)**:

Este método é simples e instala a versão mais recente do kubectl.

```bash
# 1. Baixar o binário mais recente
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# 2. (Opcional) Baixar o checksum para validar
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"

# 3. Validar o binário (deve retornar "kubectl: OK")
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

# 4. Instalar o kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

> *Nota*: Para clusters Kubernetes v1.33.x, o kubectl versão v1.32, v1.33 ou v1.34 são compatíveis.

Ponto de Verificação:

```bash
kubectl version --client
```

Deve exibir a versão do cliente `kubectl` instalada.

**Documentação Oficial**: [Install and Set Up kubectl on Linux](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/).

### Helm (Gerenciador de Pacotes)

Usaremos o Helm para instalar o Cilium no cluster. O Helm simplifica o gerenciamento de aplicações Kubernetes através de charts.

**Instalação (método script oficial)**:

```bash
# Baixar e executar o script de instalação oficial do Helm
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
```

**Alternativamente, se você usa `snap`**:

```bash
sudo snap install helm --classic
```

**Ponto de Verificação**:

```bash
helm version
```

Deve exibir a versão do Helm instalada.

**Documentação Oficial**: [Helm - Getting Started](https://helm.sh/docs/intro/install/).

### Cilium CLI

O Cilium CLI será usado para instalar, verificar o status e diagnosticar o Cilium no cluster Kind.

**Instalação (script oficial)**:

Este script detecta a arquitetura do seu sistema (amd64/arm64), baixa a versão estável mais recente e instala em `/usr/local/bin`.

```bash
# 1. Obter a versão estável mais recente do Cilium CLI
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)

# 2. Detectar a arquitetura
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi

# 3. Baixar o binário e o checksum
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}

# 4. Validar o checksum
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum

# 5. Extrair e instalar
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin

# 6. Limpar arquivos temporários
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
```

**Ponto de Verificação**:

```bash
cilium version
```

Deve exibir a versão do Cilium CLI instalada.

**Documentação Oficial**: [Cilium CLI Download](https://docs.cilium.io/en/stable/installation/cli-download/).

### Resumo dos Pontos de Verificação da Etapa 1

Execute todos os comandos abaixo em sequência. Se todos retornarem sem erro, a Etapa 1 está concluída.

```bash
docker --version          # Deve exibir a versão do Docker

kubectl version --client  # Deve exibir a versão do kubectl

helm version              # Deve exibir a versão do Helm

cilium version            # Deve exibir a versão do Cilium CLI
```

Se algum comando falhar, verifique a instalação correspondente antes de prosseguir para a **Etapa 2: Configuração do Kind (kind-lab.yaml)**.

## Etapa 2: Configuração do Kind (`kind-lab.yaml`)

Nesta etapa, vamos criar o arquivo de configuração que define todas as características do cluster `kind-lab`. Este arquivo será usado pelo comando `kind create cluster` para provisionar o ambiente exatamente conforme seus requisitos.

### Entendendo a Estrutura do Arquivo

O Kind utiliza um formato YAML com `apiVersion: kind.x-k8s.io/v1alpha4` para descrever o cluster. A estrutura principal é composta por:

| Campo        | Descrição |
| :----------- | :-------- |
| `name`       | Nome do cluster (usado para gerenciamento e contexto do kubectl) |
| `nodes`      | Lista de nós, cada um com `role` (control-plane ou worker)         |
| `networking` | Configurações de rede do cluster (CNI, kube-proxy, sub-redes)    |

**Documentação Oficial**: [Kind Configuration](https://kind.sigs.k8s.io/docs/user/configuration/)

### Configuração dos Nós (Nodes)

Cada nó no Kind é um contêiner Docker que executa os componentes do Kubernetes. Para o cluster `kind-lab`, você precisa de:

- **1 nó control-plane** com limitação de recursos: `cpu=1000m, memory=1024Mi`
- **3 nós workers** com limitação de recursos: `cpu=2000m, memory=4096Mi`

A limitação de recursos é implementada através de `system-reserved` no kubelet. O Kind permite customizar os argumentos do kubelet usando `kubeadmConfigPatches`.

> **Importante**: O campo `system-reserved` reserva recursos para o sistema, o que significa que o kubelet não agendará pods que consumam além da capacidade disponível. Para o control-plane, a sintaxe correta é:

```yaml
kubeadmConfigPatches:
- |
  kind: InitConfiguration
  nodeRegistration:
    kubeletExtraArgs:
      system-reserved: "cpu=1000m,memory=1024Mi"
```

Para os workers, como eles se juntam ao cluster (não fazem `init`), a sintaxe usa `JoinConfiguration`:

```yaml
kubeadmConfigPatches:
- |
  kind: JoinConfiguration
  nodeRegistration:
    kubeletExtraArgs:
      system-reserved: "cpu=2000m,memory=4096Mi"
```

**Documentação de Referência**:

- [Stack Overflow: Kind system-reserved](https://stackoverflow.com/revisions/77963503/1)
- [Kind Configuration - Kubeadm Config Patches](https://kind.sigs.k8s.io/docs/user/configuration/)

### Imagem do Kubernetes (v1.33.1)

Para especificar a versão exata do Kubernetes, usamos o campo `image` em cada nó:

```yaml
image: kindest/node:v1.33.1
```

**Documentação de Referência**: [Kind Releases](https://github.com/kubernetes-sigs/kind/releases)

### Configurações de Rede (Networking)

O bloco `networking` controla o comportamento de rede do cluster:

| Campo | Valor	Descrição |
| :---- | :-------------- |
| `disableDefaultCNI` | `true`   | Desativa o CNI padrão (Kindnet), permitindo instalar o Cilium |
| `kubeProxyMode`     | `"none"` | Desativa o kube-proxy, pois o Cilium fará o kube-proxy replacement |

```yaml
networking:
  disableDefaultCNI: true
  kubeProxyMode: "none"
```

**Documentação de Referência**:

- [Kind Configuration - Networking](https://kind.sigs.k8s.io/docs/user/configuration/)
- [Cilium kube-proxy replacement](https://notes.kodekloud.com/docs/Prep-Course-Cilium-Certified-Associate-CCA-Certification/Exploring-Cilium/Kube-Proxy-less/page)

### Mapeamento de Portas (extraPortMappings)

Para expor as portas `80` e `443` do host para o cluster, usamos `extraPortMappings` no nó control-plane:

```yaml
extraPortMappings:
- containerPort: 80
  hostPort: 80
  protocol: TCP
- containerPort: 443
  hostPort: 443
  protocol: TCP
```

**Documentação de Referência**: [Kind Configuration - Extra Port Mappings](https://kind.sigs.k8s.io/docs/user/configuration/)

### Arquivo Final (`kind-lab.yaml`)

Com base em todos os requisitos, o arquivo completo fica assim:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: kind-lab
nodes:
# Control Plane
- role: control-plane
  image: kindest/node:v1.33.1
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        system-reserved: "cpu=1000m,memory=1024Mi"
# Worker 1
- role: worker
  image: kindest/node:v1.33.1
  kubeadmConfigPatches:
  - |
    kind: JoinConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        system-reserved: "cpu=2000m,memory=4096Mi"
# Worker 2
- role: worker
  image: kindest/node:v1.33.1
  kubeadmConfigPatches:
  - |
    kind: JoinConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        system-reserved: "cpu=2000m,memory=4096Mi"
# Worker 3
- role: worker
  image: kindest/node:v1.33.1
  kubeadmConfigPatches:
  - |
    kind: JoinConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        system-reserved: "cpu=2000m,memory=4096Mi"
networking:
  disableDefaultCNI: true
  kubeProxyMode: "none"
```

### Ponto de Verificação

Antes de prosseguir, valide o arquivo criado:

**Verificar a sintaxe YAML (se você tiver `yamllint` instalado)**:

```bash
yamllint kind-lab.yaml
```

O comando não deve reportar erros.

**Verificar o conteúdo**:

```bash
cat kind-lab.yaml
```

Confirme visualmente que:

- O `name` é `kind-lab`
- Há 4 nós: 1 `control-plane` e 3 `worker`
- Todos os nós têm `image: kindest/node:v1.33.1`
- O control-plane tem `system-reserved: "cpu=1000m,memory=1024Mi"`
- Os workers têm `system-reserved: "cpu=2000m,memory=4096Mi"`
- `disableDefaultCNI: true` e `kubeProxyMode: "none"` estão presentes
- As portas `80` e `443` estão mapeadas

**Verificar a disponibilidade da imagem**:

```bash
docker pull kindest/node:v1.33.1
```

Este comando baixa a imagem do nó. Se já estiver disponível localmente, ele confirmará que a imagem existe.

## Etapa 3: Criação do Cluster

Nesta etapa, vamos usar o arquivo `kind-lab.yaml` criado na Etapa 2 para provisionar o cluster `kind-lab`. Como o CNI padrão está desativado, os nós ficarão no estado `NotReady` até que o Cilium seja instalado.

### Pré-requisito: Arquivo de Configuração

Certifique-se de que o arquivo `kind-lab.yaml` está no diretório atual e contém a configuração completa da Etapa 2. Se você ainda não o criou, retorne à Etapa 2 ou salve o arquivo novamente.

Ponto de Verificação:

```bash
cat kind-lab.yaml | head -5
```

Deve exibir as primeiras linhas do arquivo, confirmando que ele existe e está acessível.

### Comando de Criação do Cluster

O comando para criar o cluster é `kind create cluster --config kind-lab.yaml`. O Kind lerá o arquivo de configuração, fará o pull da imagem `kindest/node:v1.33.1` (se ainda não estiver em cache local) e criará os contêineres Docker que representam os nós do cluster.

> **Importante**: O pull da imagem pode demorar alguns minutos na primeira execução, pois a imagem `kindest/node:v1.33`.1 tem um tamanho considerável (aproximadamente 800MB a 1GB). Se você já executou `docker pull kindest/node:v1.33.1` na Etapa 2, o Kind usará a imagem em cache e a criação será muito mais rápida.

Execute:

```bash
kind create cluster --config kind-lab.yaml
```

**Documentação Oficial**: [Kind Quick Start](https://kind.sigs.k8s.io/docs/user/quick-start/#creating-a-cluster)

### Comportamento Esperado Durante a Criação

Durante a execução do comando, você verá uma saída similar a esta:

```text
Creating cluster "kind-lab" ...
 ✓ Ensuring node image (kindest/node:v1.33.1) 🖼
 ✓ Preparing nodes 📦 📦 📦 📦  
 ✓ Writing configuration 📜 
 ✓ Starting control-plane 🕹️ 
 ✓ Installing StorageClass 💾 
 ✓ Joining worker nodes 🚜 
Set kubectl context to "kind-kind-lab"
You can now use your cluster with:

kubectl cluster-info --context kind-kind-lab

Have a question, bug, or feature request? Let us know! https://kind.sigs.k8s.io/#community 🙂
```

> **Observação**: A linha "Installing CNI" aparecerá mesmo com `disableDefaultCNI: true`, pois o Kind ainda prepara a configuração base. O CNI funcional (Cilium) será instalado na Etapa 4.

### Solução de Problemas Comuns

Se a criação falhar, verifique estes cenários comuns documentados pelo Kind :

| Sintoma | Causa Provável | Solução |
| :------ | :------------- | :------ |
| **Timeout ao puxar imagem**      | Conexão lenta ou registry bloqueado                 | Configure um mirror Docker ou faça docker pull kindest/node:v1.33.1 manualmente antes |
| **Conflito de sub-rede**         | Rede `172.17.x.x` já usada por VPN ou outro serviço | Reconforme daemon.json do Docker para usar outra faixa |
| **Espaço em disco insuficiente** | Cache do Docker cheio                               | Execute docker system prune para limpar dados não usados |
| **Erro de cgroups no WSL2**      | Configuração de cgroups do WSL2 incompatível        | Siga o workaround documentado |

Se o comando falhar, execute `kind delete cluster --name kind-lab` para limpar qualquer estado parcial antes de tentar novamente.

### Ponto de Verificação: Nós Criados

Após o comando terminar, verifique se os 4 nós foram criados:

```bash
kubectl get nodes -o wide
```

Saída esperada:

```text
NAME                     STATUS     ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                         KERNEL-VERSION     CONTAINER-RUNTIME
kind-lab-control-plane   NotReady   control-plane   31m   v1.33.1   172.18.0.3    <none>        Debian GNU/Linux 12 (bookworm)   7.0.0-31-generic   containerd://2.1.1
kind-lab-worker          NotReady   <none>          31m   v1.33.1   172.18.0.4    <none>        Debian GNU/Linux 12 (bookworm)   7.0.0-31-generic   containerd://2.1.1
kind-lab-worker2         NotReady   <none>          31m   v1.33.1   172.18.0.2    <none>        Debian GNU/Linux 12 (bookworm)   7.0.0-31-generic   containerd://2.1.1
kind-lab-worker3         NotReady   <none>          31m   v1.33.1   172.18.0.5    <none>        Debian GNU/Linux 12 (bookworm)   7.0.0-31-generic   containerd://2.1.1
```

**O status `NotReady` é esperado e correto**. Como o CNI padrão está desativado, o kubelet não consegue configurar a rede dos pods, e os nós permanecem neste estado até que o Cilium seja instalado. Este comportamento é documentado e esperado no Kind .

### Pontos de Verificação Adicionais

Confirmar o contexto do kubectl:

```bash
kubectl config current-context
```

Deve retornar `kind-kind-lab`.

Verificar os contêineres Docker (nós do cluster):

```bash
docker ps --filter "name=kind-lab"
```

Deve listar 4 contêineres: `kind-lab-control-plane`, `kind-lab-worker`, `kind-lab-worker2`, `kind-lab-worker3`.

Verificar informações do cluster:

```bash
kubectl cluster-info
```

Deve exibir o endpoint do control plane e do CoreDNS .

Confirmar que o Kindnet NÃO está presente:

```bash
kubectl get pods -n kube-system | grep kindnet
```

Este comando não deve retornar nada. Se retornar pods com kindnet no nome, significa que o disableDefaultCNI não foi aplicado corretamente, e o cluster precisa ser recriado .

### Ponto de Verificação: Limitações de Recursos

Para validar que as limitações de `system-reserved` foram aplicadas corretamente, inspecione um dos nós:

```bash
kubectl describe node kind-lab-control-plane | grep -A 5 "Capacity:"
```

Saída esperada (valores aproximados):

```text
Capacity:
  cpu:                2
  memory:             2048Mi
  pods:               110
```

A capacidade exibida será o total de recursos do contêiner Docker (definido pelo Docker), e o `system-reserved` reduzirá o `Allocatable` disponível para pods. Para verificar o `Allocatable`:

```bash
kubectl get node kind-lab-control-plane -o jsonpath='{.status.allocatable}'
```

O valor de `cpu` e `memory` no `allocatable` será menor que no `capacity`, refletindo a reserva do sistema.

> **Nota**: O Kind não expõe diretamente o system-reserved no kubectl describe node. Para confirmar que foi aplicado, você pode verificar os logs do kubelet ou inspecionar o arquivo de configuração dentro do nó:

```bash
docker exec kind-lab-control-plane cat /var/lib/kubelet/config.yaml | grep -A 2 systemReserved
```

**Documentação de Referência**: [Kubernetes: Allocating Node Resources](https://kubernetes.io/docs/tasks/administer-cluster/reserve-compute-resources/)

Resumo dos Pontos de Verificação da Etapa 3:

| Verificação | Comando | Resultado Esperado |
| :---------- | :------ | :----------------- |
| Nós criados        | `kubectl get nodes`                              | 4 nós, todos `NotReady` |
| Contexto correto   | `kubectl config current-context`                 | `kind-kind-lab`         |
| Contêineres Docker | `docker ps --filter name=kind-lab`               | 4 contêineres           |
| Kindnet ausente    | `kubectl get pods -n kube-system | grep kindnet` | Nenhum resultado        |
| Cluster info       | `kubectl cluster-info`                           | Endpoint exibido        |

## Etapa 4: Instalação do Cilium

Com os nós em estado `NotReady`, vamos instalar o Cilium. Ele atuará como CNI (substituindo o Kindnet) e como kube-proxy replacement, além de habilitar o Gateway API para roteamento L7.

### Pré-requisito: CRDs do Gateway API

O Cilium Gateway API requer que as CRDs do Gateway API estejam instaladas no cluster antes de habilitar o recurso no Helm.

Instale a versão **standard** do Gateway API (compatível com a maioria dos casos de uso de roteamento HTTP/HTTPS e gRPC):

```bash
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.1/standard-install.yaml
```

**Documentação de Referência**:

- [Cilium: Gateway API Support](https://docs.cilium.io/en/stable/network/servicemesh/gateway-api/)
- [Gateway API Releases](https://github.com/kubernetes-sigs/gateway-api/releases)

Ponto de Verificação:

```bash
kubectl get crd | grep gateway
```

Deve listar `gatewayclasses.gateway.networking.k8s.io`, `gateways.gateway.networking.k8s.io`, `httproutes.gateway.networking.k8s.io`, `grpcroutes.gateway.networking.k8s.io`, entre outras.

### Instalação do Cilium via Helm

O Cilium será instalado com três configurações essenciais para o seu cenário:

| Configuração | Valor | Propósito |
| :----------- | :---- | :-------- |
| `kubeProxyReplacement` | `true` | Substitui o kube-proxy (que foi desativado no Kind) |
| `gatewayAPI.enabled`   | `true` | Habilita o controlador do Gateway API |
| `l7Proxy`              | `true` | Habilita o proxy L7 (Envoy) para roteamento de aplicação |

```bash
helm repo add cilium https://helm.cilium.io/
helm repo update

helm install cilium cilium/cilium --version 1.17.3 \
  --namespace kube-system \
  --set kubeProxyReplacement=true \
  --set gatewayAPI.enabled=true \
  --set l7Proxy=true
```

> **Nota sobre a versão**: A versão `1.17.3` é indicada como referência. Você pode verificar a versão estável mais recente compatível com Kubernetes v1.33.1 na [documentação oficial do Cilium](https://docs.cilium.io/en/stable/network/kubernetes/compatibility/).

**Documentação de Referência**:

- [Cilium: Quick Installation](https://docs.cilium.io/en/stable/gettingstarted/k8s-install-default/)
- [Cilium Helm Values](https://docs.cilium.io/en/stable/helm-values/)

### Ponto de Verificação: Status do Cilium

Aguarde o Cilium estabilizar e verifique o status:

```bash
cilium status --wait
```

Saída esperada:

text
    /¯¯\
 /¯¯\__/¯¯\    Cilium:             OK
 \__/¯¯\__/    Operator:           OK
 /¯¯\__/¯¯\    Envoy DaemonSet:    OK
 \__/¯¯\__/    Hubble Relay:       disabled
    \__/       ClusterMesh:        disabled

DaemonSet              cilium             Desired: 4, Ready: 4/4, Available: 4/4
Deployment             cilium-operator    Desired: 1, Ready: 1/1, Available: 1/1
Containers:            cilium             Running: 4
                       cilium-operator    Running: 1
                       cilium-envoy       Running: 4
Cluster Pods:          0/0 managed by Cilium
Pontos de Verificação Adicionais:

Nós agora devem estar Ready:

bash
kubectl get nodes
Todos os 4 nós devem exibir Ready.

GatewayClass do Cilium criada:

bash
kubectl get gatewayclass cilium
Deve exibir ACCEPTED: True.

Pods do Cilium em execução:

bash
kubectl get pods -n kube-system -l k8s-app=cilium
kubectl get pods -n kube-system -l name=cilium-operator
kubectl get pods -n kube-system -l k8s-app=cilium-envoy
Todos devem estar Running.

4.4 Teste de Conectividade
Execute o teste de conectividade abrangente do Cilium, que valida rede, políticas e datapath :

bash
cilium connectivity test
Este teste deploys pods temporários, valida comunicação pod-to-pod, pod-to-service, DNS, e políticas de rede. Pode levar de 5 a 15 minutos.

Saída esperada:

text
✅ All XX tests (XXX actions) successful, X tests skipped.
Documentação de Referência:

Cilium: End-To-End Connectivity Testing

4.5 Resumo dos Pontos de Verificação da Etapa 4
Verificação	Comando	Resultado Esperado
CRDs do Gateway API	kubectl get crd | grep gateway	Lista de CRDs
Status do Cilium	cilium status --wait	Cilium: OK, Operator: OK
Nós Ready	kubectl get nodes	4 nós Ready
GatewayClass	kubectl get gatewayclass cilium	ACCEPTED: True
Conectividade	cilium connectivity test	Todos os testes passam
Com a Etapa 4 concluída, o cluster kind-lab está operacional e pronto para os próximos passos: a criação de um Gateway e rotas HTTP/gRPC para expor seus serviços via *.0a0f1419.nip.io.
















## 












## 
















## 




























