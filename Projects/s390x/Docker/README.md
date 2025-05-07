# Docker on s390x

## Install Docker on s390x

> **Note**: running as root

```bash
## updatea the package index
apt update

## install packages to allow apt to use a repository over HTTPS
apt install apt-transport-https ca-certificates curl software-properties-common

## add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

## add Docker's repository to apt sources
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

## update the package index
apt update

## make sure you are about to install from the Docker repo instead of the default Ubuntu repo
apt-cache policy docker-ce

## install Docker
apt install docker-ce

## verify that Docker is running
systemctl status docker
```

## Docker behind a proxy

```bash
## create a directory
sudo mkdir -p /etc/systemd/system/docker.service.d/

## create a file 
sudo touch /etc/systemd/system/docker.service.d/http-proxy.conf
```

Put the following content in the file `http-proxy.conf`:

```bash
[Service]
Environment="HTTP_PROXY=<proxy_addr>:8000"
Environment="HTTPS_PROXY=<proxy_addr>:8000"
Environment="NO_PROXY=localhost,127.0.0.1"
```

> **Note**: replace `<proxy_addr>` with the address of your proxy server.

```bash
## reload systemd manager configurations
sudo systemd daemon-reload

## restart docker
sudo systemd restart docker
```

## Using Docker without sudo (optional)

```bash
## add your username to the docker group
sudo usermod -aG docker ${USER}
## or
sudo usermod -aG docker <USERNAME>

## logout and back in with your user account

## confirm that your user is now added to the docker group
getent group docker
groups
```

## Checking Docker installation

> **Note**: running as root

```bash
## check docker version
docker --version

## more detailed information
docker version

## docker deamon status
systemctl status docker

## if docker is not running, start it
systemctl start docker

## to ensure docker is started at boot
systemctl enable docker

## comprehensive information about the docker daemon
docker info
```

## Running Docker

```bash
## hello world container
docker run hello-world

## nginx container
docker run -d -p 8080:80 nginx

## list containers running
docker ps

## list all containers
docker ps -as

## stop container
docker stop <{CONTAINER ID} | {NAME}> ...

## remove container
docker rm <{CONTAINER ID} | {NAME}> ...

docker container rm <{CONTAINER ID} | {NAME}> ...

## list images
docker images

docker image ls

## remove image
docker rmi <{REPOSITORY:TAG} | {IMAGE ID}> ...

docker image rm <{REPOSITORY:TAG} | {IMAGE ID}> ...
```
