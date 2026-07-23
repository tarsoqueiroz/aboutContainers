# Podman 0a100: Enterprise & Production-Ready Systems

## Sobre

Visando cobrir o conteúdo do livro "PODMAN IN PRODUCTION: Containers, Orchestration, and Observability with Podman" de Wolfgang Kerschbaumer de forma lógica, incremental e prática.

A estrutura foi dividida em 8 Sessões Acadêmicas/Práticas (com duração sugerida de 5 horas por sessão, dependendo da profundidade desejada). Cada sessão foi desenhada para levar o aluno de um nível iniciante/intermediário até a arquitetura avançada de produção e segurança.

## Conteúdo

- **Nível I**: Fundamentos - Sessões 1 e 2
- **Nível II**: Ciclo de Vida - Sessões 3, 4 e 5
- **Nível III**: Rede & Sec - Sessões 6 e 7
- **Nível IV**: Orquestração - Sessão 8

### Sessão 1: Fundamentos e Arquitetura Daemonless

**Objetivo**: Compreender a filosofia do Podman (arquitetura sem daemon), a importância do ecossistema de ferramentas modulares e como o Linux gerencia containers sob o capô.

**Conteúdo Programático**:

A Filosofia do Podman:

  - O fim do daemon: O modelo Fork, Exec, Exit.
  - Ecossistema Modular: A filosofia de uma única função por ferramenta (containers/).
  - Padrões OCI (Open Container Initiative).
  - Compatibilidade com Docker: Como o Podman atua como ponte de migração.
  - Casos de uso: Quando utilizar e quando não utilizar o Podman.

Primitivos de Containers no Linux:

  - Desmistificando: "Um container é apenas um processo isolado".
  - Namespaces: PID (árvore de processos), UTS (hostname), IPC (memória compartilhada), User (o segredo do rootless) e Cgroup.
  - Cgroups v2 e Limites de Recursos: Criação de hierarquias, gerenciamento via arquivos e delegação em modo rootless.
  - Segurança no Kernel: Capabilities do Linux, chamadas de sistema (Seccomp) e LSMs (SELinux/AppArmor).
  - Do comando CLI ao Spec OCI (geração do runtime).

### Sessão 2: Instalação, Configuração e Máquinas Virtuais

**Objetivo**: Instalar o Podman em diferentes sistemas operacionais, compreender a cascata de arquivos de configuração e dominar o diagnóstico da ferramenta.

**Conteúdo Programático**:

Instalação Multiplataforma:

  - Instalação nativa no Linux (pré-requisitos do host).
  - Podman Machine (macOS e Windows): Arquitetura, providers de virtualização e o sistema operacional embarcado na VM.

A Cascata de Configuração do Podman:

  - Regra 1: Prioridade de leitura de arquivos únicos (first found wins).
  - Regra 2: Fusão de diretórios de drop-in organizados por ordem alfabética.
  - Uso de variáveis de ambiente e módulos.

Anatomia dos 4 Arquivos Críticos:

  - `containers.conf` (comportamento do runtime).
  - `storage.conf` (drivers de armazenamento e caminhos).
  - `registries.conf` (espelhamento, busca e segurança de registros).
  - `policy.json` (políticas de assinatura de imagens).

Estrutura de Diretórios e Diagnóstico:

  - O que realmente é gravado no disco (estrutura de pastas no host).
  - Uso avançado do comando `podman info` como porta de entrada para troubleshooting.

### Sessão 3: O Motor Rootless (Containers sem Root)

**Objetivo**: Dominar a funcionalidade mais poderosa do Podman: rodar containers de forma totalmente segura sem privilégios de administrador.

**Conteúdo Programático**:

A Mecânica do Rootless:

  - Como uma sessão rootless é inicializada.
  - O papel do processo de pause (manutenção de namespaces).

Mapeamento de IDs de Usuário:

  - Mapeamento subordinado: Compreendendo `/etc/subuid` e `/etc/subgid`.
  - Mapeamento duplo em prática: As flags `--uidmap` e `--gidmap`.
  - Modos de Namespace de Usuário (`--userns`).

Armazenamento e Permissões:

  - Permissões de volumes na prática (UID/GID do host vs. UID/GID do container).
  - Armazenamento Rootless: Uso do Native OverlayFS sem root.

Restrições e Workarounds no Host:

  - Delegação de Cgroup v2 para limites de recursos em modo rootless.
  - O fallback silencioso para cgroupfs.
  - Restrições de rede: Portas baixas (abaixo de 1024), ping e compartilhamento de privilégios.
  - Limitações conhecidas: O que o modo Rootless ainda não consegue fazer.

### Sessão 4: Engenharia de Imagens com Podman e Buildah

**Objetivo**: Criar imagens eficientes, seguras e multiplataforma utilizando o motor de build do Podman e a ferramenta especializada Buildah.

**Conteúdo Programático**:

Builds Modernos com Podman:

  - O motor por trás do `podman build` (BuildKit/buildah).
  - Funcionalidades modernas do Containerfile: Heredocs e imagens multi-stage estruturadas.
  - Gerenciamento de contexto de build nomeados (Named Build Contexts).
  - Injeção segura de segredos: Argumentos de build (`ARG`), segredos em tempo de build (`--secret`) e repasse de agente SSH (`--ssh`).

Estratégias de Cache e Multi-Arquitetura:

  - Os 3 tipos de cache: Layer Cache tradicional, Cache Mounts (otimização de gerenciadores de pacotes) e cache remoto baseado em registro.
  - Construção de imagens multi-arquitetura: Manifests Lists e Farm Builds (compilação distribuída).
  - Resolução de nomes curtos e busca qualificada de imagens.

Criação de Imagens Avançada com Buildah:

  - Filosofia: Um motor de build (Buildah) com dois front-ends (CLI e scripts).
  - O fluxo de build scriptado (sem Containerfile): `from`, `run`, `copy`, `config` e `commit`.
  - Acesso direto ao rootfs usando `buildah unshare` e `buildah mount`.
  - Utilização do Buildah em pipelines de Integração Contínua (CI) rodando dentro de containers (Docker-in-Docker/Podman-in-Podman).

### Sessão 5: Distribuição com Skopeo e Ciclo de Vida do Container

**Objetivo**: Inspecionar e movimentar imagens eficientemente com Skopeo, e gerenciar o ciclo de vida completo de execução de containers e volumes.

**Conteúdo Programático**:

Distribuição de Imagens com Skopeo:

  - A versatilidade do Skopeo e o conceito de transports (naming schemes).
  - Inspeção remota de imagens e listagem de tags sem realizar o download (pull).
  - Cópia eficiente entre registros (autenticação, tratamento de TLS e preservação de multi-arquitetura).
  - Distribuição em ambientes isolados (Air-Gapped): Exportação de imagens únicas e sincronização em lote com `skopeo sync`.
  - Manutenção de registros: Espelhamentos declarativos, automação via systemd e deleção de tags remotas.

Execução de Containers e Armazenamento (Runtime):

- Consequências de execução daemonless (quem monitora o container se o Podman sair?).
- Ciclo de vida completo do container: Códigos de saída (exit codes), logs de execução e entrada secundária via `podman exec`.
- Estratégias de volumes e mounts (`--mount` matrix).
- Ajuste fino de permissões de volumes: Relabeling SELinux (`:z` e `:Z`), chowning dinâmico (`:U`) e idmapped mounts.
- Criação de volumes como unidades do systemd.

### Sessão 6: Redes Avançadas: Netavark e pasta

**Objetivo**: Dominar a arquitetura de rede do Podman para containers com privilégios (Netavark) e sem privilégios (pasta).

**Conteúdo Programático**:

Rede Rootful (Netavark):

  - A arquitetura da stack Netavark (configurações baseadas em arquivos).
  - Criação de redes personalizadas vs. a rede padrão do sistema.
  - Drivers de rede: `bridge`, `macvlan` e `ipvlan`.
  - A camada de firewall: Integração com o `firewalld` e sobrevivência a reloads de regras do host.
  - Isolamento estrito entre redes internas e resolução de nomes nativa com `aardvark-dns`.
  - Configuração avançada: Dual Stack (IPv6), múltiplas redes anexadas e rotas estáticas.

Rede Rootless de Alta Performance (pasta):

  - Por que a ferramenta `pasta` substituiu o antigo `slirp4netns`.
  - Mapeamento de pacotes e endereçamento IP: Como o container enxerga o endereço IP do host.
  - Isolamento de containers sob `pasta` e acesso seguro ao host via `host.containers.internal`.
  - Publicação de portas: Portas privilegiadas (abaixo de 1024), protocolos suportados (TCP, UDP, ICMP) e IP de bind padrão.
  - Redes bridge rootless: O modelo padrão `rootlessport` vs. o experimental `pesto` (preservação do IP de origem).

### Sessão 7: Segurança Avançada e Cadeia de Suprimentos

**Objetivo**: Implementar a arquitetura de segurança de defesa em profundidade (Defense-in-Depth) e garantir a integridade das imagens do build até a execução.

**Conteúdo Programático**:

Hardening do Container Runtime:

  - O modelo de segurança baseado em camadas independentes.
  - Remoção de privilégios desnecessários através de Capabilities.
  - Restrição de chamadas de sistema (Seccomp) e separação de processos (SELinux).
  - Sistemas de arquivos somente-leitura (`--read-only`) e proteção contra escalada de privilégios (`no-new-privileges`).
  - Isolamento de dispositivos físicos e proteção de caminhos mascarados do sistema.
  - O subsistema de segredos nativo do Podman.
  - Hands-on: Construção de um checklist de hardening de containers do início ao fim.

Segurança da Cadeia de Suprimentos (Supply Chain):

  - Anatomia de uma política de confiança de imagem local (`policy.json`).
  - Assinatura criptográfica com Sigstore (chaves estáticas, configuração em `registries.d`, assinatura no push e validação no pull).
  - Esquema de assinatura legado baseado em GPG.
  - Garantia de builds reprodutíveis e geração de SBOMs (Software Bill of Materials) em tempo de compilação.
  - Gatilhos de varredura de vulnerabilidades (hooks) em pipelines de CI/CD.

### Sessão 8: Orquestração Local com Systemd, Quadlet, Compose e Kubernetes

**Objetivo**: Substituir soluções complexas de orquestração por uma arquitetura enxuta de produção rodando sob o systemd e integrada com o ecossistema Kubernetes.

**Conteúdo Programático**:

A Revolução do Quadlet (systemd-native):

  - Por que o systemd é o orquestrador ideal para infraestruturas de borda (edge) e servidores únicos.
  - O funcionamento do gerador de arquivos Quadlet.
  - Os tipos de arquivos suportados: `.container`, `.pod`, `.volume`, `.network`, `.image`, `.build`, `.artifact` e `.kube`.
  - Depuração de geração de arquivos e uso de templates/instâncias do systemd.
  - Atualizações automáticas integradas com reversão em caso de falha (Auto-update with rollback).

Pods, Compose e APIs de Compatibilidade:

  - O modelo de Pods no Podman: O papel do container de infraestrutura (infra container), redes compartilhadas e recursos do pod.
  - Ativação de sockets sob demanda via systemd para a API de compatibilidade do Docker.
  - Compatibilidade com Docker Compose: Uso do utilitário `podman-compose` vs. Docker Compose nativo apontando para o socket do Podman.

Integração e Portabilidade Kubernetes:

  - Geração de manifests declarativos Kubernetes a partir de pods locais via `podman kube generate`.
  - Execução de manifests do Kubernetes localmente sem cluster usando `podman kube play` (limitações de fidelidade de campos, mapeamento de volumes, ConfigMaps e Secrets).
  - Uso de unidades `.kube` no Quadlet: Rodando arquivos YAML declarativos diretamente sob o controle do systemd.

Comparativo de Arquiteturas:

  - Análise lado a lado de soluções: Podman + Quadlet vs. Docker Swarm vs. HashiCorp Nomad vs. Kubernetes (k3s).

### Atividades Práticas (Labs)

Para garantir a fixação do conteúdo, execução dos seguintes laboratórios práticos ao longo do treinamento:

- **Lab 1 (Sessão 1 e 2)**: Instalar o Podman e reconfigurar o armazenamento local em storage.conf para apontar para um disco secundário, validando a alteração com podman info.
- **Lab 2 (Sessão 3)**: Configurar um usuário rootless, mapear UID/GID via /etc/subuid e montar um volume de host garantindo que as permissões de leitura/escrita funcionem dentro e fora do container.
- **Lab 3 (Sessão 4 e 5)**: Escrever um script em Bash utilizando o buildah para criar uma imagem minimalista a partir do zero (scratch) sem usar um arquivo Containerfile tradicional, e exportar essa imagem para um ambiente offline usando skopeo sync.
- **Lab 4 (Sessão 6)**: Criar duas redes Netavark com isolamento estrito entre elas e demonstrar a comunicação entre containers de uma mesma rede por meio de DNS nativo com aardvark-dns.
- **Lab 5 (Sessão 7)**: Configurar uma política de segurança rígida que impede a execução de qualquer imagem que não esteja assinada por uma chave GPG/Sigstore específica gerada durante o treinamento.
- **Lab 6 (Sessão 8 - Projeto Final)**: Criar uma aplicação multi-container (ex: Nginx + App Python + PostgreSQL) totalmente orquestrada por arquivos Quadlet (.container, .network, .volume) gerenciados pelo systemd, incluindo testes de health check automáticos e rollback de versão.

## Sessão 1: Fundamentos e Arquitetura Daemonless

### A FILOSOFIA DO PODMAN

#### O Fim do Daemon: O Modelo Fork, Exec, Exit

No modelo tradicional de containers (como o Docker), existe um serviço central em segundo plano (daemon `dockerd`) rodando como `root`. A CLI atua apenas como um cliente enviando chamadas API HTTP via socket para esse serviço.

O Podman elimina essa dependência através da arquitetura **Daemonless**:

- **Modelo Fork/Exec/Exit**: Quando o usuário executa `podman run`, o binário do Podman utiliza as chamadas de sistema nativas do Linux (`fork` e `exec`) para disparar o processo diretamente a partir do shell.
- **O papel do `conmon` (Container Monitor)**: Após iniciar o container, o comando `podman` encerra (`exit`). Para acompanhar o ciclo de vida do container sem a necessidade de um daemon pesado, entra em cena o `conmon`: um utilitário ultraleve em C que monitora o processo, coleta logs de `stdout`/`stderr`, salva o exit code e mantém os sockets de TTY.
- **Vantagens de Auditoria**: Como o processo do container é um filho direto da sessão do usuário, o subsistema de auditoria do Linux (`auditd`) preserva o **UID real** (`auid`) de quem disparou o comando, garantindo rastreabilidade total.

#### Ecossistema Modular (`containers/`)

Diferente de soluções monolíticas, o Podman faz parte de uma filosofia Unix: "*faça apenas uma coisa, mas faça-a bem*". O projeto é mantido pela organização open source **containers** no GitHub e é composto por bibliotecas e ferramentas especializadas:

- `containers/storage`: Biblioteca que gerencia camadas de imagens e sistemas de arquivos (OverlayFS).
- `containers/image:` Biblioteca responsável pelo pull, push e inspeção de imagens em registros OCI.
- `containers/common`: Configurações compartilhadas entre as ferramentas do ecossistema.
- Ferramentas Especializadas:
  - **Buildah**: Focada exclusivamente em construir imagens de container.
  - **Skopeo**: Focada em inspecionar, copiar e mover imagens entre registros sem precisar baixá-las.
  - **Podman**: Focada no gerenciamento do ciclo de vida de containers, pods e volumes.

#### Padrões OCI (Open Container Initiative)

O Podman é 100% aderente aos padrões abertos da OCI:

- **OCI Image Specification**: Define a estrutura e o formato das imagens de container (camadas tarball, manifestos e arquivos de configuração JSON).
- **OCI Runtime Specification**: Define como o ambiente de execução do container deve ser configurado no disco (o arquivo `config.json` ou Spec OCI).
- **Runtimes de Baixo Nível**: O Podman não executa o container diretamente; ele gera o Spec OCI e invoca um runtime compatível, como `crun` (escrito em C, extremamente rápido e leve) ou `runc` (escrito em Go).

#### Compatibilidade com Docker: Ponte de Migração

O Podman foi projetado para ser um substituto direto (drop-in replacement) do Docker na linha de comando:

- **Sintaxe e Aliases**: A CLI do Podman espelha os comandos do Docker. É comum a criação de aliases no sistema: `alias docker=podman`.
- **Socket de Emulação**: Para ferramentas e IDEs que dependem da API REST do Docker (como VS Code ou Docker Compose), o Podman disponibiliza um socket de compatibilidade (`podman.sock`) ativado sob demanda via systemd.

#### Casos de Uso: Quando Utilizar e Quando Não Utilizar

**Quando utilizar o Podman**:

- Ambientes corporativos que exigem conformidade rigorosa de segurança (Zero Trust, rootless obrigatorio).
- Execução de containers integrados nativamente ao **systemd** (servidores Linux e ambientes Edge).
- Auditoria de segurança avançada e rastreabilidade via `auditd`.
- Desenvolvimento local seguro sem conceder privilégios de `root` aos desenvolvedores.

**Quando NÃO utilizar (ou avaliar com cautela)**:

- Ambientes que dependem fortemente de extensões de rede legadas baseadas exclusivamente na arquitetura interna do Docker.
- Ferramentas antigas de terceiros com acoplamento rígido e não padronizado à API interna do `dockerd` (que não respeitam os padrões OCI).

### LAB 0: Preparação Rápida do Ambiente (Setup Simplificado)

> **Nota**: O processo detalhado de instalação avançada, arquivos de configuração e Podman Machine em macOS/Windows será aprofundado na Sessão 2. Este laboratório visa apenas garantir o ambiente operacional para a Sessão 1.

#### Objetivos

- Instalar o pacote básico do Podman no host.
- Executar o comando de diagnóstico inicial sem privilégios administrativos.

#### Passo a Passo

Instalação do Pacote:

- RHEL / Fedora:

```sh
sudo dnf install -y podman
```

- Ubuntu / Debian:

```sh
sudo apt-get update && sudo apt-get install -y podman
```

Validação do Ambiente Rootless:

Execute o diagnóstico com o seu usuário comum (sem `sudo`).

```sh
podman info
```

#### Questão da Dinâmica - Lab 0

Observe a saída do comando `podman info` nas seções `host` e `store`.

- Qual é o driver de armazenamento (`graphDriverName`) em uso no seu sistema?
- O campo `rootless` na seção de segurança está marcado como `true`?

Gabarito & Orientação Pedagógica:

- Resposta Esperada:

  - `graphDriverName: overlay` (ou `vfs` em ambientes antigos/não suportados).
  - `rootless: true`.

- Orientações Adicionais:

  - Se o driver retornado for `vfs`, o sistema está em modo de fallback (lento e com alto consumo de disco). Isso indica que o Kernel não suporta OverlayFS rootless nativo ou que os módulos necessários não foram carregados.
  - A linha `rootless: true` confirma que a CLI está operando de forma 100% não-privilegiada.

### PRIMITIVAS DE CONTAINERS NO LINUX

```txt
                   ┌─────────────────────────────────────────┐
                   │          PROCESSO DO CONTAINER          │
                   └─────────────────────────────────────────┘
                                       │
            ┌──────────────────────────┴──────────────────────────┐
            ▼                          │                           ▼
┌─────────────────────────┐            │                 ┌─────────────────┐
│       NAMESPACES        │            │                 │   CGROUPS V2    │
│  Isolamento de Visão    │            │                 │ Limite Recursos │
│ (PID, User, Net, Mount) │            │                 │ (CPU, RAM, I/O) │
└─────────────────────────┘            │                 └─────────────────┘
                                       │
                                       ▼
                          ┌──────────────────────────┐
                          │    SEGURANÇA KERNEL      │
                          │ (Capabilities, Seccomp,  │
                          │     SELinux/AppArmor)    │
                          └──────────────────────────┘
```

#### Desmistificando: "Um container é apenas um processo isolado"

No ecossistema Linux, **não existe uma chamada de sistema `create_container()`**.

Um container é um processo comum no sistema operacional, porém executado sob restrições estritas impostas pelo Kernel por meio de três pilares fundamentais:

- **Namespaces**: O que o processo pode enxergar.
- **Cgroups**: O quanto o processo pode consumir.
- **Mecanismos de Segurança (Seccomp/Capabilities/LSM)**: O que o processo pode fazer.

#### Namespaces do Kernel

Os Namespaces fatiam os recursos globais do sistema em instâncias virtuais isoladas:

- **PID (Process ID)**: Isola a árvore de processos. O processo principal do container enxerga a si mesmo como `PID 1`, omitindo todos os outros processos do host.
- **UTS (UNIX Timesharing System)**: Permite que o container tenha seu próprio hostname e nome de domínio de forma independente do host.
- **IPC (Inter-Process Communication)**: Isola recursos de comunicação interprocessos, como filas de mensagens do System V e segmentos de memória compartilhada (POSIX shared memory).
- **User Namespace (O Segredo do Rootless)**: Mapeia um intervalo de UIDs/GIDs do host para UIDs/GIDs dentro do container. Permite que o `UID 1000` no host atue como `UID 0` (`root`) dentro do container, sem conceder poderes de administrador no sistema real.
- **Mount (mnt)**: Isola os pontos de montagem da árvore de diretórios, garantindo que o container veja apenas o seu próprio sistema de arquivos rootfs.
- **Network (net)**: Isola interfaces de rede, tabelas de roteamento, regras de firewall e portas de conexões.

#### Cgroups v2 e Limites de Recursos

Os **Control Groups (Cgroups)** gerenciam a alocação de recursos de hardware:

- **Hierarquia Unificada no Cgroups v2**: O Cgroups v2 substituiu a arquitetura legada (v1) por uma árvore única organizando todos os controladores (CPU, Memória, I/O, PIDs).
- **Delegação Rootless**: A grande vantagem do Cgroups v2 no Podman é a capacidade do Kernel de delegar subárvores de controle para usuários não-privilegiados via `systemd --user`.
- **Gerenciamento via Arquivos**: As configurações de limites são refletidas no pseudosistema de arquivos `/sys/fs/cgroup/`.

#### Segurança no Kernel

O hardening do container ocorre no nível do Kernel:

- **Capabilities do Linux**: Quebram o poder absoluto do `root` em pequenos privilégios granulares. O Podman, por padrão, remove capabilities perigosas (como `CAP_SYS_ADMIN` e `CAP_NET_ADMIN`).
- **Seccomp (Secure Computing Mode)**: Filtra e bloqueia chamadas de sistema (syscalls) perigosas que o processo tenta fazer diretamente ao Kernel.
- **LSMs (Linux Security Modules - SELinux / AppArmor)**: O SELinux aplica **MCS (Multi-Category Security)**, atribuindo labels únicas (ex: `system_u:system_r:container_t:s0:c10,c20`) aos processos e volumes, impedindo que um container acesse o sistema de arquivos do host ou de outros containers.

#### Do Comando CLI ao Spec OCI (Geração do Runtime)

Quando você executa um comando como podman run:

```txt
[podman run] ──► [Lê configurações & imagem] ──► [Gera rootfs e config.json (Spec OCI)] ──► [Invoca crun/runc]
```

- O Podman lê os parâmetros passados via CLI e arquivos de configuração.
- A biblioteca `containers/storage` prepara o sistema de arquivos montado (rootfs).
- O Podman gera um arquivo estandardizado OCI chamado `config.json` (o Spec OCI) contendo todas as definições de Namespaces, Cgroups, Capabilities e variáveis de ambiente.
- O Podman chama o runtime de baixo nível (como o `crun`), passando a localização do `config.json` para que o container seja finalmente criado.

### LAB 1: Inspeção da Árvore de Processos, Namespaces e Segurança

#### Objetivos

- Criar um container em segundo plano utilizando um nome totalmente qualificado (FQDN).
- Identificar a relação entre os PIDs do `conmon`, do processo master e dos processos trabalhadores no host.
- Inspecionar os Namespaces e o User Namespace (mapeamento subuid) diretamente no Kernel.

#### Passo a Passo

Executar o container web de testes:

```sh
podman run -d --name meu-web-teste -p 8080:80 docker.io/library/nginx:alpine
```

Inspecionar a árvore de processos no host:

```sh
ps aux | grep -E "conmon|nginx"
```

Identificar os Namespaces do processo master do Nginx:

Substitua <PID_NGINX_MASTER> pelo PID do processo nginx: master process obtido no passo anterior.

```sh
ls -l /proc/<PID_NGINX_MASTER>/ns
```

Inspecionar o mapeamento de User Namespace (subuid):

sh
cat /proc/<PID_NGINX_MASTER>/uid_map

#### Questões da Dinâmica - Lab 1

- Quem figura como processo pai (`PPID`) do processo do Nginx no host? É o binário do `podman` ou o utilitário `conmon`?
- Observando o resultado do comando `ps aux`, qual o **UID** do processo `nginx: master` e qual o UID dos processos `nginx: worker` no host? Por que o UID do worker não é o mesmo do master?
- O que a saída do arquivo `/proc/<PID_NGINX_MASTER>/uid_map` revela sobre o mapeamento de usuários?

Gabarito & Orientação Pedagógica:

- Resposta Esperada:

  - O processo pai direto é o `conmon`. O processo `podman` que iniciou a execução já encerrou (modelo *Fork/Exec/Exit*).
  - O processo `nginx: master` roda com o UID do usuário comum do host (ex: `1000` / `<USUARIO>`). Os `worker processes` rodam sob um UID elevado (ex: `100100`).
    *Explicação*: Dentro do container, o Nginx troca a execução dos workers para o usuário sem privilégios `nginx` (UID 101 dentro do container). Fora do container, o User Namespace soma o UID interno (101) ao primeiro ID da faixa alocada em `/etc/subuid` (ex: 100000 + 100 = 100100).
  - A saída exibe algo como `0 1000 1` na primeira linha e `1 100000 65536` na segunda linha, mostrando que o UID `0` interno é o UID 1000 no host, e os UIDs `1-65536` internos mapeiam para a faixa `100000-165536` do host.

- Orientação Adicional:

  - Verificar a diferença entre Docker e Podman: no Docker todos os processos ficariam debaixo do PID do `dockerd` como `root`, enquanto no Podman o processo master é do usuário não-privilegiado e o `conmon` é o monitor responsável.
  - Se ocorrer o erro de ***short-name resolution*** ao tentar puxar `nginx:alpine` sem o prefixo `docker.io/library/`, esse é um comportamento de segurança intencional do Podman e será tema da Sessão 2 (`registries.conf`).

## Sessão 2: Instalação, Configuração e Máquinas Virtuais

### INSTALAÇÃO MULTIPLATAFORMA

#### Instalação Nativa no Linux (Pré-requisitos do Host)

O Podman é uma ferramenta nativa do Linux, pois depende diretamente das chamadas de sistema e das funcionalidades do Kernel para isolamento de processos.

Pré-requisitos do Host:

- **Kernel Linux**: Versão 4.18 ou superior (recomenda-se 5.x+ para suporte completo e performático a Cgroups v2 e Native OverlayFS rootless).
- **Suporte a Cgroups v2**: Essencial para a delegação de recursos em modo rootless sem a necessidade de privilégios de administrador.
- **Configuração de SubUID/SubGID**: Os arquivos `/etc/subuid` e `/etc/subgid` devem conter faixas alocadas para usuários comuns (geralmente 65.536 UIDs por usuário, ex: `tarso:100000:65536`).
- **Dependências de Infraestrutura**: Pacotes de runtime de baixo nível (`crun` ou `runc`), utilitários de rede (`netavark` e `aardvark-dns` para **rootful/rootless**, ou `pasta` / `slirp4netns` para redes não-privilegiadas).

Comandos de Instalação Nativa por Distribuição:

- RHEL / Rocky / AlmaLinux / Fedora:

```sh
sudo dnf install -y podman
```

- Ubuntu (22.04+) / Debian (11+):

```sh
sudo apt-get update && sudo apt-get install -y podman
```

#### Podman Machine (macOS e Windows)

Como sistemas como macOS e Windows não possuem o Kernel Linux nativamente, o Podman utiliza uma abordagem cliente-servidor leve chamada **Podman Machine**.


```txt
┌───────────────────────────────────────────────────────────┐
│ HOST (macOS / Windows)                                    │
│                                                           │
│  [CLI do Podman] ──(SSH / Unix Socket API)──┐             │
└─────────────────────────────────────────────│─────────────┘
                                              ▼
┌───────────────────────────────────────────────────────────┐
│ VIRTUAL MACHINE (Fedora CoreOS / Linux Minimalist)        │
│                                                           │
│  [Podman Engine] ──► [conmon] ──► [crun] ──► [Containers] │
└───────────────────────────────────────────────────────────┘
```

Arquitetura:

- A CLI do Podman roda diretamente no sistema host do usuário (macOS ou Windows).
- O Podman gerencia automaticamente uma Máquina Virtual Linux minimalista dedicada, baseada em **Fedora CoreOS** (um SO imutável e otimizado para containers).
- A comunicação entre a CLI do host e o motor dentro da VM ocorre via SSH seguro e sockets de API repassados (*socket forwarding*).

Provedores de Virtualização (Providers):

- **macOS**:

  - `vfkit` (padrão em versões recentes, utiliza o ecossistema nativo Apple Hypervisor framework).
  - qemu (provedor alternativo e legado).

- **Windows**:

  - `wsl` (Windows Subsystem for Linux v2 - recomendado e integrado ao SO).
  - `hyperv` (Hyper-V da Microsoft).

Comandos Principais do Podman Machine:

- **Criar a VM**: `podman machine init --cpus 2 --memory 4096 --disk-size 20`
- **Iniciar a VM**: `podman machine start`
- **Verificar status**: `podman machine list`
- **Acessar a VM via SSH (para debug)**: `podman machine ssh`

### A CASCATA DE CONFIGURAÇÃO DO PODMAN

Diferente do Docker (que concentra a maioria das configurações em um único arquivo /etc/docker/daemon.json), o Podman possui uma arquitetura de configuração flexível e multinível baseada na arquitetura Linux Drop-in Directories.

txt
[Prioridade Alçada - Mais Alta]
 1. Variáveis de Ambiente (ex: CONTAINERS_CONF) e Módulos CLI (--config)
 2. Configurações de Usuário Rootless (~/.config/containers/)
 3. Drop-in do Sistema (/etc/containers/containers.conf.d/*.conf)
 4. Arquivo Global do Sistema (/etc/containers/containers.conf)
 5. Drop-in dos Pacotes (/usr/share/containers/containers.conf.d/*.conf)
 6. Arquivo Padrão de Fábrica (/usr/share/containers/containers.conf)
[Prioridade Alçada - Mais Baixa]
2.1 Regra 1: Prioridade de Leitura de Arquivos Únicos (First Found Wins)
Para arquivos de configuração principais (containers.conf, storage.conf), o Podman busca o arquivo na árvore de diretórios e aplica a regra do primeiro que encontrar, vence:

Escopo do Usuário (Rootless): ~/.config/containers/<arquivo>.conf (sobrescreve tudo para o usuário).

Escopo do Sistema (Administrador): /etc/containers/<arquivo>.conf (configuração global do servidor).

Escopo de Distribuição/Pacote: /usr/share/containers/<arquivo>.conf (padrão de fábrica do sistema operacional).

2.2 Regra 2: Fusão de Diretórios Drop-in
Para permitir que automações (Ansible, Puppet) ou pacotes adicionem configurações sem alterar o arquivo principal, o Podman suporta diretórios drop-in (.conf.d):

Diretórios Suportados:

/usr/share/containers/<arquivo>.conf.d/

/etc/containers/<arquivo>.conf.d/

~/.config/containers/<arquivo>.conf.d/

Regra de Ordenação Alfabética: Arquivos dentro desses diretórios são lidos e mesclados em ordem alfabética estrita (ex: 00-base.conf, 10-custom.conf, 99-override.conf). Arquivos com números maiores sobrescrevem definições anteriores.

2.3 Uso de Variáveis de Ambiente e Módulos
As configurações podem ser alteradas em tempo de execução sem editar arquivos em disco:

Variáveis de Ambiente Globais:

CONTAINERS_CONF: Aponta para um arquivo containers.conf customizado.

CONTAINERS_STORAGE_CONF: Sobrescreve o caminho do storage.conf.

CONTAINERS_REGISTRIES_CONF: Sobrescreve a localização do registries.conf.

Módulos (containers.conf modules): O Podman permite carregar blocos de configuração sob demanda via CLI usando a flag --module (ex: podman --module /caminho/modulo.conf run ...).

### ANATOMIA DOS 4 ARQUIVOS CRÍTICOS










## Sessão 3: O Motor Rootless (Containers sem Root)

**Conteúdo Programático**:

A Mecânica do Rootless:

  - Como uma sessão rootless é inicializada.
  - O papel do processo de pause (manutenção de namespaces).

Mapeamento de IDs de Usuário:

  - Mapeamento subordinado: Compreendendo `/etc/subuid` e `/etc/subgid`.
  - Mapeamento duplo em prática: As flags `--uidmap` e `--gidmap`.
  - Modos de Namespace de Usuário (`--userns`).

Armazenamento e Permissões:

  - Permissões de volumes na prática (UID/GID do host vs. UID/GID do container).
  - Armazenamento Rootless: Uso do Native OverlayFS sem root.

Restrições e Workarounds no Host:

  - Delegação de Cgroup v2 para limites de recursos em modo rootless.
  - O fallback silencioso para cgroupfs.
  - Restrições de rede: Portas baixas (abaixo de 1024), ping e compartilhamento de privilégios.
  - Limitações conhecidas: O que o modo Rootless ainda não consegue fazer.

## Sessão 4: Engenharia de Imagens com Podman e Buildah

**Conteúdo Programático**:

Builds Modernos com Podman:

  - O motor por trás do `podman build` (BuildKit/buildah).
  - Funcionalidades modernas do Containerfile: Heredocs e imagens multi-stage estruturadas.
  - Gerenciamento de contexto de build nomeados (Named Build Contexts).
  - Injeção segura de segredos: Argumentos de build (`ARG`), segredos em tempo de build (`--secret`) e repasse de agente SSH (`--ssh`).

Estratégias de Cache e Multi-Arquitetura:

  - Os 3 tipos de cache: Layer Cache tradicional, Cache Mounts (otimização de gerenciadores de pacotes) e cache remoto baseado em registro.
  - Construção de imagens multi-arquitetura: Manifests Lists e Farm Builds (compilação distribuída).
  - Resolução de nomes curtos e busca qualificada de imagens.

Criação de Imagens Avançada com Buildah:

  - Filosofia: Um motor de build (Buildah) com dois front-ends (CLI e scripts).
  - O fluxo de build scriptado (sem Containerfile): `from`, `run`, `copy`, `config` e `commit`.
  - Acesso direto ao rootfs usando `buildah unshare` e `buildah mount`.
  - Utilização do Buildah em pipelines de Integração Contínua (CI) rodando dentro de containers (Docker-in-Docker/Podman-in-Podman).

## Sessão 5: Distribuição com Skopeo e Ciclo de Vida do Container

**Conteúdo Programático**:

Distribuição de Imagens com Skopeo:

  - A versatilidade do Skopeo e o conceito de transports (naming schemes).
  - Inspeção remota de imagens e listagem de tags sem realizar o download (pull).
  - Cópia eficiente entre registros (autenticação, tratamento de TLS e preservação de multi-arquitetura).
  - Distribuição em ambientes isolados (Air-Gapped): Exportação de imagens únicas e sincronização em lote com `skopeo sync`.
  - Manutenção de registros: Espelhamentos declarativos, automação via systemd e deleção de tags remotas.

Execução de Containers e Armazenamento (Runtime):

- Consequências de execução daemonless (quem monitora o container se o Podman sair?).
- Ciclo de vida completo do container: Códigos de saída (exit codes), logs de execução e entrada secundária via `podman exec`.
- Estratégias de volumes e mounts (`--mount` matrix).
- Ajuste fino de permissões de volumes: Relabeling SELinux (`:z` e `:Z`), chowning dinâmico (`:U`) e idmapped mounts.
- Criação de volumes como unidades do systemd.

## Sessão 6: Redes Avançadas: Netavark e pasta

**Conteúdo Programático**:

Rede Rootful (Netavark):

  - A arquitetura da stack Netavark (configurações baseadas em arquivos).
  - Criação de redes personalizadas vs. a rede padrão do sistema.
  - Drivers de rede: `bridge`, `macvlan` e `ipvlan`.
  - A camada de firewall: Integração com o `firewalld` e sobrevivência a reloads de regras do host.
  - Isolamento estrito entre redes internas e resolução de nomes nativa com `aardvark-dns`.
  - Configuração avançada: Dual Stack (IPv6), múltiplas redes anexadas e rotas estáticas.

Rede Rootless de Alta Performance (pasta):

  - Por que a ferramenta `pasta` substituiu o antigo `slirp4netns`.
  - Mapeamento de pacotes e endereçamento IP: Como o container enxerga o endereço IP do host.
  - Isolamento de containers sob `pasta` e acesso seguro ao host via `host.containers.internal`.
  - Publicação de portas: Portas privilegiadas (abaixo de 1024), protocolos suportados (TCP, UDP, ICMP) e IP de bind padrão.
  - Redes bridge rootless: O modelo padrão `rootlessport` vs. o experimental `pesto` (preservação do IP de origem).

## Sessão 7: Segurança Avançada e Cadeia de Suprimentos

**Conteúdo Programático**:

Hardening do Container Runtime:

  - O modelo de segurança baseado em camadas independentes.
  - Remoção de privilégios desnecessários através de Capabilities.
  - Restrição de chamadas de sistema (Seccomp) e separação de processos (SELinux).
  - Sistemas de arquivos somente-leitura (`--read-only`) e proteção contra escalada de privilégios (`no-new-privileges`).
  - Isolamento de dispositivos físicos e proteção de caminhos mascarados do sistema.
  - O subsistema de segredos nativo do Podman.
  - Hands-on: Construção de um checklist de hardening de containers do início ao fim.

Segurança da Cadeia de Suprimentos (Supply Chain):

  - Anatomia de uma política de confiança de imagem local (`policy.json`).
  - Assinatura criptográfica com Sigstore (chaves estáticas, configuração em `registries.d`, assinatura no push e validação no pull).
  - Esquema de assinatura legado baseado em GPG.
  - Garantia de builds reprodutíveis e geração de SBOMs (Software Bill of Materials) em tempo de compilação.
  - Gatilhos de varredura de vulnerabilidades (hooks) em pipelines de CI/CD.

## Sessão 8: Orquestração Local com Systemd, Quadlet, Compose e Kubernetes

**Conteúdo Programático**:

A Revolução do Quadlet (systemd-native):

  - Por que o systemd é o orquestrador ideal para infraestruturas de borda (edge) e servidores únicos.
  - O funcionamento do gerador de arquivos Quadlet.
  - Os tipos de arquivos suportados: `.container`, `.pod`, `.volume`, `.network`, `.image`, `.build`, `.artifact` e `.kube`.
  - Depuração de geração de arquivos e uso de templates/instâncias do systemd.
  - Atualizações automáticas integradas com reversão em caso de falha (Auto-update with rollback).

Pods, Compose e APIs de Compatibilidade:

  - O modelo de Pods no Podman: O papel do container de infraestrutura (infra container), redes compartilhadas e recursos do pod.
  - Ativação de sockets sob demanda via systemd para a API de compatibilidade do Docker.
  - Compatibilidade com Docker Compose: Uso do utilitário `podman-compose` vs. Docker Compose nativo apontando para o socket do Podman.

Integração e Portabilidade Kubernetes:

  - Geração de manifests declarativos Kubernetes a partir de pods locais via `podman kube generate`.
  - Execução de manifests do Kubernetes localmente sem cluster usando `podman kube play` (limitações de fidelidade de campos, mapeamento de volumes, ConfigMaps e Secrets).
  - Uso de unidades `.kube` no Quadlet: Rodando arquivos YAML declarativos diretamente sob o controle do systemd.

Comparativo de Arquiteturas:

  - Análise lado a lado de soluções: Podman + Quadlet vs. Docker Swarm vs. HashiCorp Nomad vs. Kubernetes (k3s).

## That's all...

...Folks!!!

