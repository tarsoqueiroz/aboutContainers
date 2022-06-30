# Using Docker-in-Docker

## References

> `https://jpetazzo.github.io/2015/09/03/do-not-use-docker-in-docker-for-ci/`

> `https://hub.docker.com/_/docker`
> 
> `https://github.com/docker-library/docker`
>
> `https://github.com/docker-library/docker/blob/master/Dockerfile.template`
> 
> [Como (e por que) executar o Docker dentro do Docker](http://bacana.one/como-e-por-que-executar-o-docker-dentro-do-docker)
>
> [How can I run bash in a new container of a docker image?](https://stackoverflow.com/questions/43308319/how-can-i-run-bash-in-a-new-container-of-a-docker-image)
>
> [How to Keep Docker Container Running for Debugging](https://devopscube.com/keep-docker-container-running/)

## Works

```s
docker run -d -t ubuntu
docker ps -as
docker attach hopeful_morse 
docker exec -it hopeful_morse /bin/bash
docker ps 
docker stop hopeful_morse 
docker ps -as
docker rm hopeful_morse 
docker ps -as

docker run -d -t --name manager1 --rm ubuntu
docker ps -as
docker exec -it manager1 /bin/bash
docker stop manager1 
docker ps -as

docker run -d -t --rm --name manager1 -v /var/run/docker.sock:/var/run/docker.sock docker:latest
docker ps -as
docker attach manager1 
docker ps -as
docker exec -it manager1 /bin/sh
docker ps -as
```

```s
docker build -t tarsoqueiroz/tqhlf:22.04 .

docker run -d -t --rm --name hlf1 -v /var/run/docker.sock:/var/run/docker.sock tarsoqueiroz/tqhlf:22.04
docker exec -it hlf1 /bin/bash
```
