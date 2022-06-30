FROM ubuntu:22.04

WORKDIR /app
COPY docker.gpg .

RUN apt update && \
    apt install apt-transport-https ca-certificates gnupg gnupg-agent software-properties-common \
                wget curl git nano lsb-release iproute2 \
                nodejs npm python2.7 -y
RUN apt-key add docker.gpg && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu jammy stable" && \
    apt update && \
    apt install docker-ce docker-ce-cli containerd.io -y

CMD ["tail", "-f", "/dev/null"]
