# Quick Start: A Use Case Using Docker

## Source

> [Traefiklabs: Quick Start - Docker](https://doc.traefik.io/traefik/getting-started/quick-start/)

## TOC

- [Launch Traefik With the Docker Provider](#launch-traefik-with-the-docker-provider)
- [Traefik Detects New Services and Creates the Route for You](#traefik-detects-new-services-and-creates-the-route-for-you)
- [More Instances? Traefik Load Balances Them](#more-instances-traefik-load-balances-them)
- [Cleaning up lab](#cleaning-up-lab)
- [EXTRA: Using nip.io domain](#extra-using-nipio-domain)

## Launch Traefik With the Docker Provider

 [docker-compose.yaml](./resources/docker-compose.v01.yaml)

```sh
cp ./resources/docker-compose.v01.yaml ./docker-compose.yaml

docker-compose up -d reverse-proxy
```

At browser try to [http://docker.localhost:8080/api/rawdata](http://docker.localhost:8080/api/rawdata)

[Top](#quick-start-a-use-case-using-docker)

## Traefik Detects New Services and Creates the Route for You

- [docker-compose.yaml](./resources/docker-compose.v02.yaml)

```sh
cp ./resources/docker-compose.v02.yaml ./docker-compose.yaml

docker-compose up -d whoami
```

At browser try to:

1. [http://docker.localhost:8080/api/rawdata](http://docker.localhost:8080/api/rawdata)
1. [http://whoami.docker.localhost](http://whoami.docker.localhost)

[Top](#quick-start-a-use-case-using-docker)

## More Instances? Traefik Load Balances Them

```sh
docker-compose up -d --scale whoami=2

docker-compose ps

docker ps -a
```

At browser try to:

1. [http://docker.localhost:8080/api/rawdata](http://docker.localhost:8080/api/rawdata)
1. [http://whoami.docker.localhost](http://whoami.docker.localhost) (refresh with F5 some times)

[Top](#quick-start-a-use-case-using-docker)

## Cleaning up lab

```sh
docker-compose down
```

[Top](#quick-start-a-use-case-using-docker)

## EXTRA: Using nip.io domain

- [docker-compose.yaml](./resources/docker-compose.v03.yaml)

```sh
cp ./resources/docker-compose.v03.yaml ./docker-compose.yaml

docker-compose up -d reverse-proxy
```

At browser try to:

1. [http://0a0f122c.nip.io:8080/api/rawdata](http://0a0f122c.nip.io:8080/api/rawdata)
1. [http://0a0f122c.nip.io:8080](http://0a0f122c.nip.io:8080)

```sh
docker-compose up -d whoami
```

At browser try to:

1. [http://0a0f122c.nip.io:8080/api/rawdata](http://0a0f122c.nip.io:8080/api/rawdata)
1. [http://0a0f122c.nip.io:8080](http://0a0f122c.nip.io:8080)
1. [http://whoami.0a0f122c.nip.io](http://whoami.0a0f122c.nip.io)

```sh
docker-compose up -d --scale whoami=3 whoami

docker-compose ps

docker ps -a
```

At browser try to:

1. [http://0a0f122c.nip.io:8080/api/rawdata](http://0a0f122c.nip.io:8080/api/rawdata)
1. [http://0a0f122c.nip.io:8080](http://0a0f122c.nip.io:8080)
1. [http://whoami.0a0f122c.nip.io](http://whoami.0a0f122c.nip.io) (refresh with F5 some times)

```sh
docker-compose up -d whoishost

docker-compose ps

docker ps -a
```

At browser try to:

1. [http://0a0f122c.nip.io:8080/api/rawdata](http://0a0f122c.nip.io:8080/api/rawdata)
1. [http://0a0f122c.nip.io:8080](http://0a0f122c.nip.io:8080)
1. [http://whoami.0a0f122c.nip.io](http://whoami.0a0f122c.nip.io)
1. [http://whoishost.0a0f122c.nip.io](http://whoishost.0a0f122c.nip.io)

```sh
docker-compose up -d tinywebinfo

docker-compose ps

docker ps -a
```

At browser try to:

1. [http://0a0f122c.nip.io:8080/api/rawdata](http://0a0f122c.nip.io:8080/api/rawdata)
1. [http://0a0f122c.nip.io:8080](http://0a0f122c.nip.io:8080)
1. [http://whoami.0a0f122c.nip.io](http://whoami.0a0f122c.nip.io)
1. [http://whoishost.0a0f122c.nip.io](http://whoishost.0a0f122c.nip.io)
1. [http://tinywebinfo.0a0f122c.nip.io](http://tinywebinfo.0a0f122c.nip.io)

Go to [Cleaning up lab](#cleaning-up-lab) to keep everything clean. 

[Top](#quick-start-a-use-case-using-docker)

## See you soon

***That's all folks!!!***
