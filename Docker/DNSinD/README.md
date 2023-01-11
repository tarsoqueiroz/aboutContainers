# Como Funciona o DNS em Containers

> `https://www.linkedin.com/posts/activity-7015777256862052352-UXER`

## Padrão de funcionamento

Um container por padrão é associado a rede padrão bridge. Desta forma a comunicação só pode ser feita via IP.

Em processo de recriação de um container, um novo IP pode ser atribuído o que inviabiliza a comunicação desta forma.

As duas maneiras de usar o DNS em containers:

1. Recurso legado chamado link
1. Através de uma rede utilizando o driver Bridge.

Recomenda-se assim a criação de uma rede específica para o conjunto de containers/projeto. Além de um maior controle sobre o ambiente, permite-se a conexão mais fácil e clara entre os diversos containers que irão compor esse ambiente.

## Hands-on

- Criando rede bridge

```sh
docker network create net4dns -d bridge
docker network ls
```

- Verificando a rede criada

```sh
docker network inspect net4dns
```

- Criando containers para teste

```sh
docker container run -d --rm --name container01 --network net4dns busybox sleep 3600
docker container run -d --rm --name container02 --network net4dns busybox sleep 3600
docker ps -as
```

- Comunicação entre os containers

```sh
docker container exec -it container01 ping container02 -c 3
docker container exec -it container02 ping container01 -c 3
```

- Verificando endereço IP atribuido

```sh
docker container inspect container01 | jq '.[].NetworkSettings.Networks.net4dns.IPAddress'
docker container inspect container02 | jq '.[].NetworkSettings.Networks.net4dns.IPAddress'
```

- Excluindo o primeiro container

```sh
docker container stop container01
docker ps -as
```

- Criando dois novos containers

> *Obs: segundo container com nome já utilizado (**container01**)*

```sh
docker container run -d --rm --name container03 --network net4dns busybox sleep 3600
docker container run -d --rm --name container01 --network net4dns busybox sleep 3600
docker ps -as
```

- Verificando endereço IP atribuido

```sh
docker container inspect container01 | jq '.[].NetworkSettings.Networks.net4dns.IPAddress'
docker container inspect container02 | jq '.[].NetworkSettings.Networks.net4dns.IPAddress'
docker container inspect container03 | jq '.[].NetworkSettings.Networks.net4dns.IPAddress'
```

- Comunicação entre os containers

```sh
docker container exec -it container02 ping container01 -c 3
docker container exec -it container02 ping container03 -c 3
```

- Removendo containers de teste

```sh
docker container stop container01 container02 container03
docker ps -as
```

- Removendo a rede criada

```sh
docker network rm net4dns
docker network ls
```
