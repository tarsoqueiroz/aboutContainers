# Building Minimal Docker Images

## About

> [`https://dev.to/krishnaaher/building-minimal-docker-images-310c`](https://dev.to/krishnaaher/building-minimal-docker-images-310c)

Using app from:

- [Minimal HTTP Server in Go](https://github.com/tarsoqueiroz/aboutGo/tree/main/ShortTests/minimalHttp#minimal-http-server-in-go)

## Tasks

```sh
docker build -t tarsoqueiroz/minimalhttp:v1.0-go1.23.3 .

docker image ls
docker image ls tarsoqueiroz/*

docker run -p 8910:8910 tarsoqueiroz/minimalhttp:v1.0-go1.23.3 

docker ps

docker build -t tarsoqueiroz/minimalhttp:v1.0-go1.22.11 .
docker image ls tarsoqueiroz/*

docker run --rm -p 8910:8910 tarsoqueiroz/minimalhttp:v1.0-go1.22.11 

docker ps -a

docker run -d --rm --name minimalhttp -p 9999:8910 tarsoqueiroz/minimalhttp:v1.0-go1.23.3
docker run -d --rm --name minimalhttp -p 8765:8910 tarsoqueiroz/minimalhttp:v1.0-go1.23.3 
```
