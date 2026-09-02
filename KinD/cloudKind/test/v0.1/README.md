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

## Configuração do Kind

O arquivo `kind-config.yaml` irá conter as informações de configuração do cluster com o mapeamento de portas de entrada no Control-Plane, a desativação do CNI padrão e os limites de recursos por nó,

- [`kind-config.yaml`](./manifestos/kind-config.yaml)

> Nota sobre Limites de Hardware**: 
> 
> Para aplicar restrições físicas estritas nos containers Docker que representam os nós, você também pode limitar via Docker após criar o cluster:
> 
> - docker update --cpus 2 --memory 2g kind-control-plane
> - docker update --cpus 2 --memory 4g kind-worker (repetindo para kind-worker2 e kind-worker3).

Execute o comando que segue para provisionar a estrutura básica:

```bash
kind create cluster --name lab-cluster --config kind-config.yaml
```

## Instalação do Cilium CNI

Com o cluster rodando (nós em estado NotReady até o CNI subir), instale o CLI do Cilium e faça o deploy ativando o Gateway API e a substituição completa do Kube-Proxy:

Instalar o Cilium CLI no host:

```bash
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name "https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz"
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz
```

Instalar os CRDs do Gateway API do Kubernetes:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/standard/gateway.networking.k8s.io_gatewayclasses.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/standard/gateway.networking.k8s.io_gateways.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/standard/gateway.networking.k8s.io_httproutes.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/standard/gateway.networking.k8s.io_referencegrants.yaml
```

Deploy do Cilium no Cluster:

```bash
cilium install \
  --set kubeProxyReplacement=true \
  --set k8sServiceHost=lab-cluster-control-plane \
  --set k8sServicePort=6443 \
  --set gatewayAPI.enabled=true \
  --set ingressController.enabled=true \
  --set ingressController.default=true \
  --set operator.replicas=1
```

Aguarde até que a rede do cluster esteja saudável:

```bash
cilium status --wait
```

## Configuração do Gateway / Ingress Controller no Control-Plane

Para fixar a entrada de tráfego no nó `control-plane` e mapear para as portas expostas (`80, 443, 8080, 8443, 9090`), crie uma configuração de **NodePort / HostNetwork** ou redirecionamento do Ingress Controller do Cilium para responder no Control-Plane:

- [`gateway-config.yaml`](./manifestos/gateway-config.yaml)

E instale o MetalLB para atribuir o IP da rede Docker ao Gateway do Cilium caso use LoadBalancer:

```bash
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.5/config/manifests/metallb-native.yaml
```

## Ajustar as Taints e Tolerations no MetalLB.

Como o nó control-plane e os workers possuem regras restritivas (taints), precisamos garantir que o Webhook do MetalLB consiga rodar e responder na rede do Cilium:

```bash
# Permitir que os pods do MetalLB sejam agendados nos trabalhadores com Taint
kubectl patch deployment controller -n metallb-system --type='json' -p='[{"op": "add", "path": "/spec/template/spec/tolerations", "value": [{"key": "workload", "operator": "Equal", "value": "app", "effect": "NoSchedule"}]}]'

kubectl patch daemonset speaker -n metallb-system --type='json' -p='[{"op": "add", "path": "/spec/template/spec/tolerations", "value": [{"key": "workload", "operator": "Equal", "value": "app", "effect": "NoSchedule"}]}]'
```

Certifique-se de que o pod do webhook está 1/1 Running:

```bash
kubectl get pods -n metallb-system
```

## Deletar temporariamente o ValidatingWebhook (Caso persista o bloqueio)

Se o Cilium ainda estiver terminando de mapear as rotas eBPF para o IP de serviço 10.96.213.179, delete o Webhook de validação do MetalLB para que a criação do recurso não seja bloqueada:

```bash
kubectl delete validatingwebhookconfigurations.admissionregistration.k8s.io metallb-webhook-configuration --ignore-not-found
```

## Aplicar a configuração com o IP correto (172.18)

Extraia o prefixo mantendo o ponto e aplica o manifesto:

```bash
# Captura correta mantendo o ponto (ex: 172.18)
NET_PREFIX=$(docker network inspect kind -f '{{range .IPAM.Config}}{{if .Gateway}}{{print .Gateway}}{{end}}{{end}}' | grep -oE '([0-9]{1,3}\.){2}' | sed 's/\.$//')

echo "Prefix definido: ${NET_PREFIX}"
# Deve imprimir: Prefix definido: 172.18

cat <<EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: kind-pool
  namespace: metallb-system
spec:
  addresses:
  - ${NET_PREFIX}.255.200-${NET_PREFIX}.255.250
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: kind-advertisement
  namespace: metallb-system
EOF
```

## Instalação da Kubernetes Dashboard e Exposição via .0a0f122c.nip.io

Deploy da Dashboard Oficial:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
```

Criar Usuário Administrador e ServiceAccount ([`dashboard-sa-role.yaml`](./manifestos/dashboard-sa-role.yaml)):

```bash
kubectl apply -f ./manifestos/dashboard-sa-role.yaml
```

Expor o Dashboard via Ingress/Gateway no domínio dashboard.0a0f122c.nip.io ([`dashboard-ingress.yaml`](./manifestos/dashboard-ingress.yaml)):

```bash
kubectl apply -f dashboard-ingress.yaml
```

Gerar Token de Acesso:

```bash
kubectl -n kubernetes-dashboard create token admin-user
```

## Garantindo a Separação de Cargas (Deploy nos Workers)

Ao publicar aplicações de teste nos workers, inclua o toleration e o nodeSelector no seu manifesto para que os pods sejam agendados exclusivamente nos nós workers ([`deploy-sample.yaml`](./manifestos/deploy-sample.yaml)):



Verificação do Ambiente
Status dos Nós: kubectl get nodes -o wide

Políticas do Cilium Ativas: cilium status

Acesso ao Dashboard: Abra o navegador e acesse [http://dashboard.0a0f122c.nip.io](http://dashboard.0a0f122c.nip.io) utilizando o token gerado.



















