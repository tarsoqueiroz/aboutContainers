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

## 
















## 




























