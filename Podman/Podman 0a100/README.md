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
            ▼                          │                          ▼
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

```sh
cat /proc/<PID_NGINX_MASTER>/uid_map
```

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

```txt
[Prioridade Alçada - Mais Alta]

  1. Variáveis de Ambiente (ex: CONTAINERS_CONF) e Módulos CLI (--config)
  2. Configurações de Usuário Rootless (~/.config/containers/)
  3. Drop-in do Sistema (/etc/containers/containers.conf.d/*.conf)
  4. Arquivo Global do Sistema (/etc/containers/containers.conf)
  5. Drop-in dos Pacotes (/usr/share/containers/containers.conf.d/*.conf)
  6. Arquivo Padrão de Fábrica (/usr/share/containers/containers.conf)

[Prioridade Alçada - Mais Baixa]
```

#### Regra 1: Prioridade de Leitura de Arquivos Únicos (First Found Wins)

Para arquivos de configuração principais (containers.conf, storage.conf), o Podman busca o arquivo na árvore de diretórios e aplica a regra do primeiro que encontrar, vence:

- **Escopo do Usuário (Rootless)**: `~/.config/containers/<arquivo>.conf` (sobrescreve tudo para o usuário).
- **Escopo do Sistema (Administrador)**: `/etc/containers/<arquivo>.conf` (configuração global do servidor).
- **Escopo de Distribuição/Pacote**: `/usr/share/containers/<arquivo>.conf` (padrão de fábrica do sistema operacional).

#### Regra 2: Fusão de Diretórios Drop-in

Para permitir que automações (Ansible, Puppet) ou pacotes adicionem configurações sem alterar o arquivo principal, o Podman suporta diretórios **drop-in** (`.conf.d`):

- **Diretórios Suportados**:
  - `/usr/share/containers/<arquivo>.conf.d/`
  - `/etc/containers/<arquivo>.conf.d/`
  - `~/.config/containers/<arquivo>.conf.d/`
- **Regra de Ordenação Alfabética**: Arquivos dentro desses diretórios são lidos e mesclados em ordem alfabética estrita (ex: `00-base.conf`, `10-custom.conf`, `99-override.conf`). Arquivos com números maiores sobrescrevem definições anteriores.

#### Uso de Variáveis de Ambiente e Módulos

As configurações podem ser alteradas em tempo de execução sem editar arquivos em disco:

- **Variáveis de Ambiente Globais**:
  - `CONTAINERS_CONF`: Aponta para um arquivo `containers.conf` customizado.
  - `CONTAINERS_STORAGE_CONF`: Sobrescreve o caminho do `storage.conf`.
  - `CONTAINERS_REGISTRIES_CONF`: Sobrescreve a localização do `registries.conf`.
- **Módulos (`containers.conf` modules)**: O Podman permite carregar blocos de configuração sob demanda via CLI usando a flag `--module` (ex: `podman --module /caminho/modulo.conf run ...`).

### ANATOMIA DOS 4 ARQUIVOS CRÍTICOS

#### `containers.conf` (Comportamento do Runtime)

Sua sintaxe é estruturada em **TOML**. Controla o comportamento do motor do Podman, escolha de runtimes de baixo nível, limites de processos e variáveis globais.

- Seções Principais:
- `[containers]`: Parâmetros padrão para execução de containers (ex: `apparmor_profile`, `seccomp_profile`, `dns_servers`, `env`).
- `[engine]`: Parâmetros do motor do Podman (ex: `cgroup_manager = "systemd"`, `runtime = "crun"`, `events_logger = "journald"`).
- `[network]`: Configurações de rede padrão (ex: `network_backend = "netavark"`).

#### `storage.conf` (Drivers de Armazenamento e Caminhos)

Gerenciado pela biblioteca containers/storage. Define como as camadas de imagem e contêineres são armazenadas no disco.

- **Parâmetros Fundamentais**:
  - `driver`: Define o driver de armazenamento. O padrão é `"overlay"`.
  - `runroot`: Diretório temporário na memória RAM para estado de execução (ex: `/run/user/1000/containers` para rootless ou `/run/containers/storage` para rootful).
  - `graphroot`: Diretório persistente onde as imagens e volumes são gravados no disco (ex: `~/.local/share/containers/storage` para rootless ou `/var/lib/containers/storage para rootful`).

#### `registries.conf` (Busca, Espelhamento e Segurança)

Define a de onde e como as imagens são baixadas, incluindo segurança para resolução de nomes curtos (*short-names*).

- **Seções e Configurações Chave**:
  - `unqualified-search-registries`: Lista de registros onde o Podman busca imagens quando o usuário não digita o FQDN completo (ex: [`"docker.io"`, `"quay.io"`]).
  - `[[registry]]`: Bloco para configurar registros específicos, permitindo definir espelhos (*mirrors*), suporte a registros sem TLS/HTTP local (`insecure = true`) ou bloqueio de registros desconfiados (`blocked = true`).
  - `short-name-mode`: Define como o Podman reage a nomes curtos (`"enforcing"`, `"permissive"`, ou `"disabled"`).

#### `policy.json` (Políticas de Assinatura de Imagens)

Um arquivo no formato **JSON** que implementa a segurança da cadeia de suprimentos (*supply chain*). Ele decide se uma imagem pode ser baixada baseando-se na verificação de assinaturas criptográficas.

- **Estrutura de Decisão**:
  - `default`: Política global aplicada a qualquer registro não especificado (geralmente configurada como `insecureAccept` em desenvolvimento ou `reject` em produção restrita).
  - `transports`: Define regras baseadas no protocolo de transporte (`docker`, `dir`, `tarball`).

### LAB 2: Reconfiguração de Armazenamento e Registros com Drop-In

#### Objetivos

- Criar e aplicar uma configuração drop-in para o `registries.conf` no escopo do usuário comum, liberando a busca automática de nomes curtos (*short-names*).
- Alterar o local de armazenagem de dados persistentes via `storage.conf` para um diretório secundário customizado.
- Validar todas as alterações utilizando o comando de diagnóstico `podman info`.

#### Passo a Passo

**Passo 1: Configurar busca de registros (Registries Drop-In)**

Crie o diretório de configuração drop-in no escopo do seu usuário comum (sem `sudo`):

```sh
mkdir -p ~/.config/containers/registries.conf.d/
```

Crie um arquivo chamado `00-shortnames.conf` no diretório recém-criado:

```sh
nano ~/.config/containers/registries.conf.d/00-shortnames.conf
```

Adicione o seguinte conteúdo em sintaxe TOML:

```ini
unqualified-search-registries = ["docker.io", "quay.io"]
```

Salve e feche o arquivo. Teste a execução puxando uma imagem usando apenas o nome curto sem a necessidade do prefixo `docker.io/library/`:

```sh
podman pull alpine:latest
```

**Passo 2: Alterar o diretório de armazenamento (Storage Config)**

Crie um diretório secundário no seu sistema de arquivos local para simular um disco secundário:

```sh
mkdir -p ~/meu_storage_podman
```

Crie o arquivo de configuração de armazenamento no escopo do usuário:

```sh
nano ~/.config/containers/storage.conf
```

Adicione o seguinte conteúdo TOML para redirecionar o graphroot:

```ini
[storage]
driver = "overlay"
graphroot = "/home/SEU_USUARIO/meu_storage_podman"
# Substitua /home/SEU_USUARIO/ pelo caminho absoluto da sua home folder!
```

Valide a alteração executando o diagnóstico do Podman:

```sh
podman info | grep -E "graphRoot|graphDriverName"
```

#### Questões da Dinâmica - Lab 2

- Ao executar o comando `podman pull alpine:latest` após criar o drop-in do `registries.conf`, qual foi o comportamento do Podman em relação à escolha do registro?
- O que o resultado do comando `podman info` mostrou referente ao campo `graphRoot`? Ele passou a apontar para o novo diretório configurado?
- Se criássemos um arquivo `/etc/containers/storage.conf` definindo o graphroot como `/var/lib/containers` e mantivéssemos o `~/.config/containers/storage.conf` apontando para `~/meu_storage_podman`, qual dos dois caminhos o Podman do seu usuário iria obedecer? Por quê?

Gabarito & Orientação Pedagógica:

- Resposta Esperada:

  - O Podman resolveu com sucesso o nome curto `alpine:latest` buscando no primeiro registro configurado na lista (`docker.io/library/alpine:latest`), sem apresentar o erro de *short-name resolution*.
  - O campo `graphRoot` no `podman info` passou a apontar para `/home/SEU_USUARIO/meu_storage_podman`.
  - O Podman irá obedecer o caminho definido em `~/.config/containers/storage.conf` (`~/meu_storage_podman`).
    - *Explicação*: A Regra 1 da cascata de configuração estabelece o princípio do *First Found Wins*. Como a configuração no escopo do usuário (`~/.config/containers/`) tem precedência sobre a do sistema (`/etc/containers/`), a regra individual do usuário sobrescreve a regra global.

- Orientações Adicionais:

  - Observe a importância de não alterar diretamente os arquivos padrão localizados em `/usr/share/containers/`.
  - Destaque onde as atualizações do sistema operacional sobrescrevem arquivos em `/usr/share/`, razão pela qual boas práticas corporativas exigem o uso do `/etc/containers/` (para o sistema) ou `~/.config/containers/` (para o usuário) usando a estrutura `.conf.d/`.

### ESTRUTURA DE DIRETÓRIOS E DIAGNÓSTICO AVANÇADO

#### Estrutura Interna de Pastas no Disco

Compreender o que é gravado em disco é fundamental para troubleshooting de armazenamento e manutenção de capacidade do host.

```txt
~/.local/share/containers/storage/ (ou /var/lib/containers/storage/)
                                 ├─ overlay/            # Camadas do OverlayFS (imagens e containers)
                                 ├─ overlay-containers/ # Metadados e pontos de montagem dos containers
                                 ├─ overlay-images/     # Metadados, manifests e gráficos de camadas das imagens
                                 ├─ storage.lock        # Arquivo de trava para controle de concorrência
                                 └─ volumes/            # Volumes locais criados pelo Podman
```

- `/run/user/<UID>/containers` (ou `/run/containers`): Fica alocado em memória RAM volatile (tmpfs). Armazena o estado atual de execução, arquivos de PID (`pidfile`), sockets do `conmon` e os arquivos do OCI Spec (`config.json`).

#### Diagnóstico Avançado com `podman info`

O comando `podman info` é o principal ponto de entrada para diagnóstico e suporte de Nível 2/3 em ambientes com Podman.

**Principais Seções do podman info para Troubleshooting**:

- `host`: Exibe a versão do Kernel, arquitetura do processador, total de memória, status de Swap, gerenciador de Cgroups (`systemd` ou `cgroupfs`) e disponibilidade dos executáveis de rede (`netavark`/`pasta`).
- `store`: Revela o driver de armazenamento ativo (`overlay`), o espaço ocupado, arquivos de configuração carregados e os caminhos reais de `graphRoot` e `runRoot`.
- `registries`: Mostra os registros de busca configurados e o modo de resolução de nomes curtos ativo.
- `plugins`: Lista os drivers de rede, de logs (`journald`, `k8s-file`) e de armazenamento de segredos disponíveis no ambiente.

### LAB 3: Diagnóstico e Troubleshooting de Armazenamento com `podman info`

#### Objetivos

- Simular uma verificação de saúde e diagnóstico no ambiente do Podman.
- Identificar onde estão localizados os arquivos de estado em tempo de execução e a versão do runtime OCI em uso.

#### Passo a Passo

Execute o comando podman info exportando o resultado filtrado para analisar as seções do host e de runtime:

```sh
podman info --format json | grep -E "ociRuntime|cgroupManager|networkBackend"
```

Inspecione o diretório temporário de execução (*runroot*) do seu usuário no sistema de arquivos temporário:

```sh
ls -la /run/user/$(id -u)/containers/overlay-containers/
```

#### Questões da Dinâmica - Lab 3

- Qual é o **runtime OCI** padrão em uso no seu sistema operacional (ex: `crun` ou `runc`)?
- Qual é o **backend de rede** reportado pelo diagnóstico (`netavark` ou `slirp4netns`/`pasta`)?
- Por que os arquivos dentro de `/run/user/<UID>/containers/` somem quando a máquina é reiniciada, enquanto os arquivos em `~/.local/share/containers/storage/` persistem?

Gabarito & Orientação Pedagógica:

- Resposta Esperada:

  - Geralmente `crun` (em distribuições modernas como Fedora, RHEL 9, Ubuntu 22.04+) ou `runc`.
  - `netavark` (padrão em instalações modernas do Podman 4.0+).
  - Porque o diretório `/run` é montado em memória RAM como um sistema de arquivos temporário (**tmpfs**), destinado a guardar apenas o estado instável de execução dos processos ativos (sockets, PIDs, specs temporários). O diretório `~/.local/share/` reside no disco rígido/SSD não volátil, onde os dados permanentes do `graphRoot` (camadas de imagens e volumes) são preservados.

- Orientação Adicional:

  - Observar a relevância do comando `podman info --format json`. O formato JSON permite integrar o diagnóstico do Podman com scripts de automação ou agentes de monitoramento (Prometheus, Zabbix) para verificar a saúde dos nós de produção.

## Sessão 3: O Motor Rootless (Containers sem Root)

### A MECÂNICA DO ROOTLESS

#### Como uma Sessão Rootless é Inicializada

A execução de containers sem privilégios administrativos (*Rootless Mode*) é a funcionalidade central de segurança do Podman. Quando um usuário comum (não-root) digita `podman run`, o sistema dispara uma sequência de inicialização para simular um ambiente isolado sem violar a segurança do sistema operacional host.

```txt
[Sessão do Usuário (Host UID 1000)]
       │
       ▼ (Acessa /etc/subuid e /etc/subgid)
 [User Namespace] ──► Mapeia UID 1000 (Host) ──► UID 0 (Container Root)
       │          ──► Mapeia SubUIDs (100000-165535) ──► UIDs 1-65536
       ▼
 [Pause Process / conmon] ──► Mantém os Namespaces ativos
       │
       ▼
 [Rootless Runtime] ──► Aplica Native OverlayFS & pasta/slirp4netns
```

- **Leitura de Tabelas Subordinadas**: O Podman consulta `/etc/subuid` e `/etc/subgid` para verificar quais faixas de IDs de usuário/grupo foram concedidas ao usuário do host.
- **Criação do User Namespace**: O Kernel cria um novo User Namespace isolado. O UID real do usuário no host (ex: `1000`) vira o UID `0` (`root`) dentro desse namespace específico.
- **Inicialização do Rootless Storage**: O Podman monta o sistema de arquivos utilizando Native OverlayFS sem privilégios (ou *fuse-overlayfs* como fallback em kernels legados).
- **Configuração da Rede Não-Privilegiada**: Como usuários não-root não podem criar interfaces bridge diretamente no host, o Podman utiliza utilitários em espaço de usuário (como `pasta` ou `slirp4netns`) para criar a pilha de rede dentro do namespace.

#### O Papel do Processo de Pause (Manutenção de Namespaces)

Em cenários onde múltiplos containers precisam compartilhar o mesmo ambiente isolado (como dentro de um **Pod** do Podman ou durante operações de rede persistentes), o Kernel exige um processo "âncora".

- **Manutenção da Vida do Namespace**: Se todos os processos dentro de um namespace terminarem, o Kernel do Linux destrói o namespace imediatamente.
- **O Container `pause`**: É um container infraestrutural de tamanho mínimo (poucos kilobytes) que é executado primeiro. Ele entra em estado de repouso (*sleep*) perpétuo para segurar os namespaces abertos (Network, IPC, User, UTS).
- **Compartilhamento de Recursos**: Todos os containers de uma mesma aplicação apontam para os namespaces mantidos pelo processo `pause`, garantindo que conexões de rede locais (`localhost`) e memórias compartilhadas persistam mesmo se a aplicação principal reiniciar.

### MAPEAMENTO DE IDS DE USUÁRIO (UID/GID MAPPING)

#### Mapeamento Subordinado: Compreendendo `/etc/subuid` e `/etc/subgid`

O segredo do isolamento rootless reside em permitir que um usuário não-privilegiado no host gerencie múltiplos "usuários virtuais" dentro dos seus containers. O Linux faz isso reservando blocos de UIDs/GIDs secundários nos arquivos do sistema `/etc/subuid` e `/etc/subgid`.

Sintaxe do arquivo `/etc/subuid`:

```txt
# USUARIO:PRIMEIRO_SUB_UID:QUANTIDADE
tarso:100000:65536
```

- `tarso`: Nome do usuário real no host.
- `100000`: O primeiro UID da faixa de reserva alocada exclusivamente para este usuário no Kernel.
- `65536`: A quantidade total de UIDs alocados em sequência (de 100000 até 165535).

**Como o Kernel traduz isso**?

| Inside Container          | Host OS Real             |
| :------------------------ | :----------------------- |
| UID 0 (root do container) | UID 1000 (tarso no host) |
| UID 1                     | UID 100000               |
| UID 100                   | UID 100100               |
| UID 65535                 | UID 165535               |

#### Mapeamento Duplo na Prática: As Flags `--uidmap` e `--gidmap`

Embora o mapeamento padrão funcione para a maioria dos casos, certas aplicações exigem que um UID específico do host seja mapeado para um UID específico no container. O Podman permite redefinir a tabela de tradução usando as flags `--uidmap` e `--gidmap`.

Sintaxe do parâmetro:

```sh
--uidmap container_id:host_id:quantidade
```

Exemplo de Sobrescrita:

```sh
podman run -it --uidmap 0:1000:1 --uidmap 1:100000:65535 alpine sh
```

- `0:1000:1`: Mapeia exatamente 1 UID no container (o UID 0) para o UID 1000 do host.
- `1:100000:65535`: Mapeia os próximos 65535 UIDs do container (UIDs 1 a 65535) para a faixa do host a partir do 100000.

#### Modos de Namespace de Usuário (`--userns`)

A flag `--userns` altera o comportamento de isolamento de usuários:

- `--userns=host`: Desativa o User Namespace isolado. O container usa a tabela de UIDs nativa do host (Requer permissões elevadas se executado como rootful; em rootless, restringe o container ao próprio UID do usuário).
- `--userns=keep-id`: Mapeia o UID real do usuário no host diretamente para o mesmo número de UID dentro do container. Se o seu usuário é UID `1000` no host, dentro do container você também será o UID `1000` (em vez de virar UID `0`). Essencial para lidar com volumes compartilhados sem alterar permissões!
- `--userns=auto`: O Podman seleciona e aloca automaticamente um bloco exclusivo e único de sub-UIDs de `/etc/subuid` especificamente para aquele container, garantindo isolamento total inclusive entre containers do mesmo usuário.

### LAB 4: Manipulação de User Namespaces e Mapeamento de UIDs

#### Objetivos

- Inspecionar os arquivos `/etc/subuid` e `/etc/subgid` do sistema.
- Executar containers variando os parâmetros `--userns=keep-id` e `--uidmap`.
- Validar a identidade dos UIDs internos e externos usando o comando `id` e a inspeção de processos no host.💻 

#### Passo a Passo

Inspecione a faixa de sub-UIDs alocada para o seu usuário no host:

```sh
grep $(whoami) /etc/subuid
```

Execute um container Alpine padrão e verifique quem você é dentro do container:

```sh
podman run --rm alpine id
```

Execute o mesmo container Alpine utilizando o modo `keep-id`:

```sh
podman run --rm --userns=keep-id alpine id
```

Execute um container com mapeamento customizado via --uidmap, atribuindo o UID 0 do container para o quinto ID relativo da sua faixa subordinada no host (evitando sobreposição nos intervalos)

```sh
podman run --rm --uidmap 0:5:1 --uidmap 1:1:65530 alpine id
```

#### Questões da Dinâmica - Lab 4

- No **Passo 2** (execução padrão), qual foi o resultado do comando `id` dentro do container?
- No **Passo 3** (`--userns=keep-id`), qual o UID e GID exibidos? Por que essa flag é útil ao trabalhar com diretórios do desenvolvedor?
- No **Passo 4**, qual foi a estratégia de mapeamento adotada nas flags --uidmap e qual UID real no host o Kernel atribuiu ao processo do container?
 
Gabarito & Orientação Pedagógica:

- Resposta Esperada:

  - `uid=0(root) gid=0(root) groups=0(root)`.
  - Exibe `uid=1000(tarso) gid=1000(tarso)` (ou o UID real do usuário no host). É extremamente útil porque os arquivos criados ou modificados dentro do container gravam no disco diretamente com a propriedade do usuário do host, evitando problemas de permissão recusada (*Permission Denied*) em código-fonte ou volumes locais.
  - Para evitar conflitos de sobreposição (*conflicts with other mappings*), dividimos o mapeamento em fatias: o UID `0` do container foi isolado no offset relativo `5`, enquanto as faixas adjacentes (`1:1:4` e `5:6:65530`) preencheram o restante do User Namespace.
  - O Kernel do host atribuiu a esse processo o UID real 100005 (calculado como: primeiro SubUID do usuário (100000) + offset relativo (5)).

- Orientações Adicionais:

  - No Passo 2 o processo parece ser root dentro do container (`uid=0`), mas na verdade é apenas o usuário comum no host.
  - No Passo 3, o processo é explicitamente o usuário `1000` dentro e fora.

### ARMAZENAMENTO E PERMISSÕES

#### Permissões de Volumes na Prática

O principal desafio em ambientes rootless é a incompatibilidade entre o proprietário do arquivo no host e o proprietário esperado pela aplicação dentro do container.

```txt
[Host File System]                 [Container File System]
/var/data (Dono: Host UID 1000) ──► Montado em /app/data (Espera: Internal UID 101/nginx)
                                            │
                                            ▼
                              ❌ ERRO: Permission Denied!
                                (Host UID 1000 não equivale ao Internal UID 101)
```

**Soluções Nativas do Podman**:

- A Suffix Flag `:U` (Chown Dinâmico):

  Ao montar um volume, adicionar o sufixo `:U` instrui o Podman a executar um `chown` recursivo no diretório montado, alterando as permissões no host para coincidir com o UID/GID que o container exige.

```sh
podman run -v ./meu_data:/var/www/html:Z,U nginx
```

- O Comando `podman unshare`:

  Permite que um usuário comum abra uma sessão de terminal **dentro do User Namespace do seu próprio ambiente rootless**. Permite manipular permissões de arquivos usando comandos padrão (`chown`, `chmod`) enxergando os sub-UIDs reais:

```sh
# Altera a propriedade do arquivo no host para o UID 101 interno do container
podman unshare chown -R 101:101 ./meu_data
```

#### Armazenamento Rootless: Native OverlayFS sem Root

Historicamente, montar um sistema de arquivos OverlayFS exigia privilégios de `root`. O Podman utilizava uma ferramenta em espaço de usuário chamada `fuse-overlayfs` (mais lenta e com consumo de CPU elevado).

- **Native OverlayFS em Modo Rootless (Kernel 5.11+)**:
  
  Atualmente, o Kernel Linux suporta a montagem nativa de OverlayFS por usuários não-privilegiados dentro de User Namespaces.
  
- **Vantagens**: Desempenho equivalente ao modo *rootful*, menor latência de E/S de disco e redução no consumo de memória RAM.

### LAB 5: Gerenciamento de Volumes e Resolução de Permissões Rootless

#### Objetivos

- Criar um diretório no host com o usuário comum e tentar montá-lo em um container que roda sob um usuário não-root interno (ex: Nginx).
- Experimentar o erro de permissão recusada e corrigi-lo utilizando o comando `podman unshare`.
- Validar a correção utilizando a flag de montagem dinâmica `:U`.

#### Passo a Passo

Crie um diretório no host e um arquivo de teste dentro dele:

```sh
mkdir -p ~/dados_app
echo "Hello Podman Storage" > ~/dados_app/index.html
```

Tente rodar um container Nginx montando esse diretório sem ajustes de permissão:

```sh
podman run --rm -v ~/dados_app:/usr/share/nginx/html:ro -p 8080:80 docker.io/library/nginx:alpine
```

> **NOTA**: Em um terminal secundário, tente acessar curl http://localhost:8080 e verifique se haverá erro 403 Forbidden nos logs por falha de leitura.

Interrompa o container e corrija a propriedade dos arquivos para a faixa do Nginx (UID 101 dentro do container) usando `podman unshare`:

``sh
podman unshare chown -R 101:101 ~/dados_app
``

Verifique como as permissões do diretório ficaram visíveis para o host fora do `unshare`:

```sh
ls -ld ~/dados_app
```

#### Questões da Dinâmica - Lab 5

- O que o comando `ls -ld ~/dados_app` revelou sobre o proprietário do diretório quando checado diretamente do host?
- Se usássemos a flag `-v ~/dados_app:/usr/share/nginx/html:Z,U` no comando podman run, precisaríamos ter executado o podman unshare chown manualmente? Por quê?

**Gabarito & Orientação Pedagógica**:

- Resposta Esperada:
  - Revelou que o proprietário no host mudou do usuário `tarso` (UID 1000) para o UID `100100` (resultado de: primeiro sub-UID 100000 + 100 da tabela interna).
  - Não, não seria necessário. A flag `:U` indica ao Podman para calcular dinamicamente a tabela de UIDs exigida pelo container e aplicar a alteração de propriedade automaticamente antes de subir o processo.

- Orientação Adicional:
  - Observar o impacto da flag `:U` em diretórios gigantescos no host (ex: terabytes de dados). Como o `:U` faz um `chown` recursivo na inicialização, em volumes muito grandes isso pode causar delay ao subir o container. Nesses casos, prefira ajustar a propriedade uma única vez via `podman unshare` ou utilizar `--userns=keep-id`.

### RESTRIÇÕES E WORKAROUNDS NO HOST

#### Delegação de Cgroup v2 para Limites de Recursos

Para que um usuário comum possa limitar CPU e Memória de seus containers (`podman run --memory 512m`), o sistema host deve ter a **delegação de Cgroups v2 ativa**.

- **O Papel do systemd**:
  
  O Podman se comunica com a sessão do usuário do systemd (`systemd --user`).

- **Como ativar a delegação no Host (Root Admin)**:
  
  No servidor, o administrador deve garantir que o arquivo `/etc/systemd/system/user@.service.d/delegate.conf` contenha:

```ini
[Service]
Delegate=cpu cpuacct io memory pids
```

- **Fallback Silencioso (`cgroupfs`)**:
  
  Se a delegação não estiver ativa ou o sistema rodar Cgroups v1, o Podman exibe um aviso e faz um fallback para o driver `cgroupfs`. Nesse cenário, **os limites de recursos definidos pelo usuário não serão aplicados rigorosamente**, e o container poderá consumir mais recursos do que o permitido.

#### Restrições de Rede Rootless

Como o usuário não-root não possui a capability `CAP_NET_BIND_SERVICE` no host:

- **Portas Privilegiadas (Abaixo de 1024)**:
  
  Por padrão, um usuário rootless não pode publicar portas abaixo de 1024 no host (ex: `-p 80:80` falhará com *Permission Denied*).
  
  - **Workaround no Host (Sysctl)**: O administrador pode liberar portas mais baixas alterando a variável do Kernel:

```sh
sudo sysctl -w net.ipv4.ip_unprivileged_port_start=80
```

- **Comando Ping (Pacotes ICMP RAW)**:
  
  Containers rootless não conseguem emitir pacotes ICMP raw por padrão.
  
  - Workaround no Host:

```sh
sudo sysctl -w net.ipv4.ping_group_range="0 2147483647"
```

#### Limitações Conhecidas do Modo Rootless

Embora extremamente poderoso, o modo Rootless possui restrições arquiteturais que devem ser consideradas no desenho da infraestrutura:

- **Incapaz de criar interfaces Bridge reais no Host**: Toda a comunicação de rede passa por tradução de pacotes em espaço de usuário (via utilitários `pasta` ou `slirp4netns`), o que gera um leve overhead de throughput de rede se comparado ao modo *rootful*.
- **Impossibilidade de realizar montagens do tipo `NFS` diretamente dentro do container**: Montagens de rede complexas devem ser feitas no host e repassadas via *bind mount*.
- **Perda do IP de Origem do Cliente (Source IP Preservation)**: Ao utilizar os drivers de rede rootless padrão, os pacotes que chegam à aplicação parecem vir da interface de loopback (`127.0.0.1` ou IP da ponte interna), mascarando o IP real do cliente (a menos que se utilize o modo avançado com `pasta` ou `rootlessport`).

### LAB 6: Diagnóstico de Limitações Rootless e Ajuste de Sysctl

#### Objetivos

- Simular a falha de bind em porta privilegiada (porta 80) em ambiente rootless.
- Aplicar a liberação via `sysctl` e validar a publicação bem-sucedida da porta.

#### Passo a Passo

Tente executar um container vinculando diretamente à porta 80 do host (porta privilegiada) com seu usuário comum:

```sh
podman run --rm -p 80:80 docker.io/library/nginx:alpine
```

> **NOTA**: Observe a mensagem de erro de permissão recusada ao tentar fazer o bind do socket.

Aplique temporariamente o workaround via sysctl (requer sudo no host para alterar o parâmetro do Kernel):

```sh
sudo sysctl -w net.ipv4.ip_unprivileged_port_start=80
```

Re-execute o comando do Passo 1:

```sh
podman run -d --rm --name web-porta80 -p 80:80 docker.io/library/nginx:alpine
```

Valide a resposta do serviço na porta 80 nativa do host:

```sh
curl http://localhost
```

Limpe o container de teste:

```sh
podman stop web-porta80
```

#### Questões da Dinâmica - Lab 6

- Qual foi a mensagem exata fornecida pelo Podman ao tentar publicar a porta 80 antes da alteração do `sysctl`?
- O parâmetro `net.ipv4.ip_unprivileged_port_start=80` concede privilégios de `root` ao usuário que disparou o container?

**Gabarito & Orientação Pedagógica**:

- Resposta Esperada:
  
  - `Error: rootlessport listen tcp 0.0.0.0:80: bind: permission denied` (ou mensagem similar indicando incapacidade de escutar em portas privilegiadas em modo não-root).
  - Não! Ele apenas altera a regra do Kernel do Linux, rebaixando a fronteira de portas consideradas "privilegiadas" de 1024 para 80. O usuário e o container continuam rodando de forma 100% não-privilegiada, protegendo o sistema contra qualquer tipo de ataque de escalada de privilégios (*privilege escalation*).
  
- Orientação Adicional:

  - Observar que o ajuste do `net.ipv4.ip_unprivileged_port_start` em `/etc/sysctl.d/` é uma prática padrão e recomendada na preparação de servidores Linux corporativos para subir aplicações web (nas portas 80/443) via Podman Rootless de forma segura.

## Sessão 4: Engenharia de Imagens com Podman e Buildah

### BUILDS MODERNOS COM PODMAN

#### O Motor por trás do `podman build`

Quando você executa o comando `podman build`, o Podman não utiliza um daemon externo (como o BuildKit do Docker). Ele utiliza internamente as bibliotecas e o mecanismo do **Buildah** como seu motor de construção nativo.

- **Arquitetura Daemonless em Builds**: A compilação ocorre como um processo direto no host ou no User Namespace do usuário (*rootless*).
- **Vantagens de Segurança**: Não há necessidade de expor sockets com privilégios de `root` para compilar imagens.
- **Compatibilidade de Sintaxe**: Suporta nativamente arquivos chamados tanto `Containerfile` quanto `Dockerfile`.

#### Funcionalidades Modernas do Containerfile

- **Heredocs (Sintaxe Inline em Múltiplas Linhas)**

Evita o encadeamento excessivo de comandos com `&&` e barras invertidas `\`. Permite criar scripts internos ou arquivos de configuração diretamente no arquivo de build.

```Dockerfile
# Syntax = docker/dockerfile:1.4
FROM registry.access.redhat.com/ubi9/ubi-minimal:latest

# Execução de script multilinha limpo
RUN <<EOF
microdnf update -y
microdnf install -y python3 tar
microdnf clean all
EOF

# Criação de arquivo diretamente no container
RUN <<EOF /etc/app.conf
[global]
env = production
debug = false
EOF
```

- **Imagens Multi-Stage Estruturadas**

O padrão *Multi-stage Build* separa o ambiente de **compilação** (que contém compiladores, SDKs e ferramentas pesadas) do ambiente de **execução final** (contendo apenas o binário estático e dependências mínimas).

```Dockerfile
# Estágio 1: Build (Compilação)
FROM docker.io/library/golang:1.22-alpine AS builder
WORKDIR /src
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o /app/server .

# Estágio 2: Imagem Final Leve
FROM registry.access.redhat.com/ubi9/ubi-micro:latest
WORKDIR /app
COPY --from=builder /app/server /app/server
USER 1001
CMD ["/app/server"]
```

#### Gerenciamento de Contexto de Build Nomeado (*Named Build Contexts*)

A instrução `--build-context` permite injetar fontes de dados dinâmicas ou imagens alternativas no momento do build sem alterar o `Containerfile`:

- **Substituição de Imagens Base em CI/CD**:

```sh
podman build --build-context alpine=docker.io/library/alpine:3.19 -t minha-app .
```

- Uso de Múltiplos Diretórios Locais: Permite mapear um segundo diretório do host para dentro do contexto de build e consumi-lo via `COPY --from=contexto_nomeado`.

#### Injeção Segura de Segredos

O compartilhamento incorreto de credenciais durante a compilação é um dos maiores riscos de segurança em containers.

```txt
❌ ARG / ENV ──────────► Gravado nas camadas da imagem! (Visível via podman history)
✅ --secret ───────────► Montado temporariamente em RAM (tmpfs) durante o RUN! Não deixa rastros.
✅ --ssh ──────────────► Repassa o agente SSH do host via socket temporário!
```

1. `ARG` **(Variáveis de Build)**: NÃO use para segredos! O valor passa para os metadados da imagem e pode ser extraído facilmente com `podman history` ou `podman inspect`.
2. `--secret` **(Montagem Temporária em Memória)**: Monta o segredo a partir de um arquivo do host em um ponto de montagem temporário em RAM durante a execução de um comando `RUN`.
  - No Containerfile: `RUN --mount=type=secret,id=meu_token cat /run/secrets/meu_token ...`
  - Na CLI: `podman build --secret id=meu_token,src=./token.txt -t minha-app .`
3. `--ssh` **(Repasse de Agente SSH)**: Permite clonar repositórios privados via SSH dentro do build sem copiar chaves privadas para a imagem.
  - No Containerfile: `RUN --mount=type=ssh git clone git@github.com:empresa/repo-privado.git`
  - Na CLI: `podman build --ssh default -t minha-app .`

### ESTRATÉGIAS DE CACHE E MULTI-ARQUITETURA

#### Os 3 Tipos de Cache de Build

1. **Layer Cache Tradicional**: O Podman reutiliza camadas existentes localmente se o comando no `Containerfile` e o hash do contexto de arquivos não mudarem.
2. **Cache Mounts (`--mount=type=cache`)**: Mantém diretórios de cache de gerenciadores de pacotes (`pip, npm, dnf, go build`) persistentes entre builds, evitando baixar dependências repetidas sem inchar a imagem final.

```Dockerfile
RUN --mount=type=cache,target=/root/.cache/go-build \
    go build -o /app/server .
```

3. **Cache Remoto Baseado em Registro (`--cache-from` / `--cache-to`)**: Exporta o estado do cache para um registro OCI remoto. Permite que pipelines de CI/CD em máquinas virtuais efêmeras reaproveitem o cache gerado por builds anteriores.

```sh
podman build \
  --cache-to=quay.io/empresa/app:cache \
  --cache-from=quay.io/empresa/app:cache \
  -t quay.io/empresa/app:v1 .
```

#### Construção Multi-Arquitetura (Manifest Lists e Farm Builds)

Uma Manifest List (ou imagem multi-arquitetura) é um ponteiro único no registro que aponta para diferentes imagens compiladas para arquiteturas distintas (ex: amd64 para servidores x86 e arm64 para Apple Silicon ou servidores AWS Graviton).

```txt
                               ┌──► Imagem Linux/amd64 (x86_64)
                               │
[quay.io/empresa/app:v1] ──────┼──► Imagem Linux/arm64 (aarch64)
    (Manifest List)            │
                               └──► Imagem Linux/s390x (Mainframe)
```

Criação de Manifest List no Podman:

```sh
# 1. Cria a lista de manifesto vazia
podman manifest create minha-app:v1

# 2. Compila e adiciona a imagem para x86_64
podman build --platform linux/amd64 --manifest minha-app:v1 .

# 3. Compila e adiciona a imagem para ARM64 (utilizando emulação QEMU se no host x86)
podman build --platform linux/arm64 --manifest minha-app:v1 .

# 4. Envia a lista completa e as imagens vinculadas para o registro
podman manifest push minha-app:v1 docker://quay.io/empresa/minha-app:v1
```

#### Resolução de Nomes Curtos e Busca Qualificada

Conforme vimos na Sessão 2, o Podman bloqueia ambiguidades de imagens para prevenir ataques de *Supply Chain*. Ao escrever um `Containerfile`, **sempre utilize FQDN**:

- **<< (NÃO) >>** `FROM alpine:latest` (Ambiguação sujeita a falha de resolução em produção)
- **<< (SIM) >>** `FROM docker.io/library/alpine:latest` (Nome qualificado seguro)

### CRIAÇÃO DE IMAGENS AVANÇADA COM BUILDAH

#### A Filosofia do Buildah

Enquanto o Podman é a ferramenta para rodar e orquestrar containers, o Buildah é a ferramenta especializada em construir imagens.

- Dois Front-Ends:

  1. **CLI declarativa baseada em arquivo**: `buildah bud` (equivalente ao `podman build`).
  1. **CLI imperativa para scripts Shell**: Comandos granulares (`buildah from`, `buildah run`, `buildah copy`) que eliminam a necessidade de escrever um `Containerfile`.

#### O Fluxo de Build Scriptado (sem Containerfile)

Com o Buildah, você pode construir imagens inteiras executando comandos em um script Bash comum. Isso permite integrar variáveis do SO, condicionais if/else complexas e ferramentas do host.

```sh
#!/usr/bin/env bash
set -e

# 1. Inicia o container de trabalho a partir de uma imagem base ou do zero (scratch)
container=$(buildah from docker.io/library/alpine:latest)

# 2. Executa comandos dentro do container em construção
buildah run $container -- apk update
buildah run $container -- apk add --no-cache curl

# 3. Copia arquivos do host para dentro do container
buildah copy $container ./app.sh /usr/local/bin/app.sh

# 4. Configura metadados da imagem
buildah config --env APP_ENV=production $container
buildah config --entrypoint '["/usr/local/bin/app.sh"]' $container
buildah config --author "DevOps Team" $container

# 5. Salva as alterações gerando uma imagem OCI final
buildah commit $container minha-imagem-scriptada:v1

# 6. Limpa o container de trabalho temporário
buildah rm $container
```

#### Acesso Direto ao Rootfs com `buildah mount`

Uma das funcionalidades mais revolucionárias do Buildah é a capacidade de **montar o sistema de arquivos (rootfs) do container em construção em uma pasta do host**.

```sh
container=$(buildah from scratch)
mountpoint=$(buildah mount $container)

# Agora você pode usar ferramentas nativas do HOST para instalar coisas direto na pasta montada!
# Exemplo: Usar o 'dnf' do host para popular um container minimalista limpo
sudo dnf install --installroot $mountpoint --releasever 9 --nodocs -y bash coreutils

buildah unmount $container
buildah commit $container minha-imagem-minimalista
```

#### Buildah em Pipelines de CI/CD (Podman-in-Podman / Docker-in-Docker)

Em sistemas de CI/CD (GitHub Actions, GitLab CI, Tekton), compilar imagens dentro de um container executor exigia montar o socket do Docker (`docker.sock`), o que quebrava o isolamento de segurança.

- **Buildah em Containers sem Privilégios**: Como o Buildah roda nativamente de forma daemonless e rootless, ele pode ser executado dentro de uma pipeline de CI que roda dentro de um container Podman ou Kubernetes de forma **100% isolada e segura**, sem precisar de `sudo` ou privilégios de `root` no nó worker do cluster!

### LAB 7: Engenharia de Imagens com Buildah Scriptado e Segredos

#### Objetivos

- Criar uma imagem OCI utilizando um **script Bash com Buildah** sem usar arquivo `Containerfile`.
- Utilizar o comando `buildah unshare` e `buildah mount` para inspecionar e manipular o rootfs do container diretamente pelo host.
- Testar a injeção segura de segredos em tempo de compilação via `podman build --secret`.

#### Passo a Passo

**Etapa A: Build Scriptado com Buildah**

Crie um script de build em Bash no seu diretório de trabalho:

```sh
nano build_com_buildah.sh
```

Adicione o seguinte conteúdo ao arquivo:

```sh
#!/usr/bin/env bash
set -eo pipefail

echo "🚀 Iniciando build com Buildah..."

# Cria container temporário a partir de Alpine
ctr=$(buildah from docker.io/library/alpine:latest)

# Instala o pacote jq dentro do container
buildah run $ctr -- apk add --no-cache jq

# Configura variável de ambiente e comando padrão
buildah config --env FERRAMENTA=jq $ctr
buildah config --cmd '["jq", "--version"]' $ctr

# Gera a imagem OCI final
buildah commit $ctr imagem-buildah:v1

# Remove o container temporário
buildah rm $ctr

echo "✅ Imagem imagem-buildah:v1 criada com sucesso!"
```

Dê permissão de execução e execute o script (como seu usuário comum, sem `sudo`):

```sh
chmod +x build_com_buildah.sh
./build_com_buildah.sh
```

Teste a execução da imagem criada pelo Buildah:

```sh
podman run --rm imagem-buildah:v1
```

**Etapa B: Acesso ao Rootfs via `buildah mount`**

Crie um novo container de trabalho a partir da imagem `scratch` (imagem vazia):

```sh
ctr_vazio=$(buildah from scratch)
```

Execute o ambiente isolado `buildah unshare` para montar e inspecionar a pasta do container no host:

```sh
buildah unshare bash -c '
  ponto_montagem=$(buildah mount '$ctr_vazio')
  echo "📁 Ponto de montagem no host: $ponto_montagem"
  echo "Servidor de Produção" > "$ponto_montagem/mensagem.txt"
  ls -la "$ponto_montagem"
  buildah unmount '$ctr_vazio'
'
```

Configure a imagem vazia e comite o resultado:

```sh
buildah config --cmd '["cat", "/mensagem.txt"]' $ctr_vazio
buildah commit $ctr_vazio imagem-scratch-mensagem:v1
buildah rm $ctr_vazio
```

Teste a execução da imagem criada a partir do `scratch`:

```sh
podman run --rm imagem-scratch-mensagem:v1
```

**Etapa C: Injeção Segura de Segredos com `--secret`**

Crie um arquivo contendo um segredo fictício no host:

```sh
echo "CHAVE_SECRET_API_PROD_12345" > token_api.txt
```

Crie um `Containerfile` que consome o segredo durante o build sem salvá-lo no resultado final:

```Dockerfile
FROM docker.io/library/alpine:latest
RUN --mount=type=secret,id=token_api \
    cat /run/secrets/token_api > /tmp/valida.txt && \
    echo "Segredo lido com sucesso durante o build!" && \
    rm -f /tmp/valida.txt
```

Execute a compilação passando o segredo via CLI:

```sh
podman build --secret id=token_api,src=token_api.txt -t app-segura:v1 .
```

Verifique com `podman history` que o segredo não foi gravado nas camadas da imagem:

```sh
podman history app-segura:v1
```

#### Questões da Dinâmica - Lab 7

- Na **Etapa A**, qual a grande vantagem prática de utilizar um script Bash com `buildah` para criar imagens em comparação com a escrita de um `Containerfile` tradicional em pipelines complexas?
- Na **Etapa B**, o container criado com `buildah from scratch` possuía algum sistema operacional ou executáveis (como `sh` ou `ls`) antes de escrevermos o arquivo `mensagem.txt` no ponto de montagem?
- Na **Etapa C**, se inspecionássemos a imagem compilada (`app-segura:v1`) após a conclusão do build, o arquivo `/run/secrets/token_api` ainda estaria presente no sistema de arquivos do container?

**Gabarito & Orientação Pedagógica**:

- Resposta Esperada:
  - A principal vantagem é o controle dinâmico e a flexibilidade. Scripts com Buildah permitem utilizar toda a sintaxe da linguagem Shell (loops `for`, condicionais `if/else`, manipulação de strings, leitura de variáveis de ambiente do host) e reaproveitar ferramentas instaladas no servidor de build, sem a rigidez da sintaxe limitada do `Containerfile`.
  - Não! A imagem `scratch` é totalmente vazia (0 bytes). Ela não possui Kernel, diretórios de sistema, nem binários. Ao usar `buildah mount`, escrevemos o arquivo `mensagem.txt` diretamente na raiz bruta do sistema de arquivos alocado pelo storage.
  - Não. O arquivo montado em `/run/secrets/` existe exclusivamente na memória RAM temporária enquanto o comando `RUN` correspondente está sendo executado. Assim que a instrução termina, o ponto de montagem do segredo é desmontado e nenhum rastro do arquivo fica registrado nas camadas salvas no disco.

- Orientações Adicionais:
  - Enfatizar que a técnica de `buildah from scratch` combinada com `buildah mount` é a base para a criação de imagens ultrafinas (*distroless*). Imagens construídas dessa forma possuem superfície de ataque praticamente zero, pois não contêm shells (como `/bin/sh` ou `/bin/bash`) que invasores pudessem explorar em caso de vulnerabilidade na aplicação.
  - Etapa A: Build scriptado com Buildah e instalação do jq em imagem leve.
  - Etapa B: Demonstração da imagem a partir do scratch — ressaltando aos alunos que o erro executable file not found in $PATH ao tentar rodar um cat é a prova de que a imagem scratch é totalmente limpa (sendo destinada apenas para binários estáticos sem dependências dinâmicas, como Go/Rust).
  - Etapa C: Injeção segura de segredos via --secret, sem persistência de credenciais no podman history.

## Sessão 5: Distribuição com Skopeo e Ciclo de Vida do Container


<<<ESTAMOS AQUI>>>


Seguindo para a Sessão 5 na mesma estrutura com o Conteúdo Programático que segue:

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

Seguindo para a Sessão 6 na mesma estrutura com o Conteúdo Programático que segue:

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

Seguindo para a Sessão 7 na mesma estrutura com o Conteúdo Programático que segue:

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

Seguindo para a Sessão 8 na mesma estrutura com o Conteúdo Programático que segue:

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

