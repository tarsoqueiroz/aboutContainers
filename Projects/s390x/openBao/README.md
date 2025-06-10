# openBao on s390x

## About

## Getting started

```bash

### in dev mode
docker run --rm -d --name openbao --cap-add=IPC_LOCK -e 'BAO_DEV_ROOT_TOKEN_ID=myroot' -e 'BAO_DEV_LISTEN_ADDRESS=0.0.0.0:8200' -p 8200:8200 openbao/openbao:2.2.2-s390x

### terminal on server
docker exec -it openbao /bin/sh

### in prod mode

# create a directory structure
mkdir -p $PWD/{certs,config,data,logs}

# create certificate
openssl req -x509 -newkey rsa:4096 -keyout ./certs/openbao-key.pem -out ./certs/openbao-cert.pem -days 365 -subj "/CN=openbao.0a0f6017.nip.io" -nodes

# create docker-compose.yml
touch docker-compose.yml

# create config.hcl
touch ./config/openbao.hcl

# docker compose up
docker-compose up -d
```

At first attempt to access the vault, you will need to initialize the vault. Go to the openBao server and run the instructions:

- `https://openbao.0a0f6017.nip.io/`

> ***note:*** Don't forget to save the unseal keys and root token in a safe place.
