# Traefik as a Proxy Service

## References

- [Docker Official Images](https://github.com/docker-library/official-images?tab=readme-ov-file#docker-official-images)
- [Architectures other than amd64?](https://github.com/docker-library/official-images#architectures-other-than-amd64)
- [IBM POWER8 (ppc64le)](https://hub.docker.com/u/ppc64le/)
- [IBM z Systems (s390x)](https://hub.docker.com/u/s390x/)

## Servidores

- Z13 - `10.15.39.70` (`0a0f2746.nip.io`)
- Power - `10.15.80.80` (`0a0f5050.nip.io`)

## Getting started

**Create certificate for `<DOMAIN>`**:

```sh
# @[PATH_PROJECT]/.certs
openssl req -newkey rsa:2048 -x509 -nodes -keyout "<DOMAIN>.key" -new -out "<DOMAIN>.crt" -subj "/CN=*.<DOMAIN>" -reqexts SAN -extensions SAN -config <(cat /etc/ssl/openssl.cnf <(printf "[SAN]\nsubjectAltName=DNS:*.%s, DNS:%s" "<DOMAIN>" "<DOMAIN>")) -sha256 -days 3650
```

**Using preconf files**:

Copy from `v1.0 template` following files:

- `docker-compose.yaml`
- `traefik.yaml`
- `dynamic.yaml`

Adjusts:

At `docker-compose.yaml`

- Image for Traefik
- Image for Whoami (sample app/server)
- Domain for Whoami
- Ports to listening (optional)

At `traefik.yaml`

- Ports on entrypoints (optional)
- HTTP redirection to HTTPS (optional)

At `dynamic.yaml`

- User/Password for basic authentication (optional)
  - Coded accounts: user/password and usuario/senha
- Adjust of names for certificate and key files

## Log rotating

Tasks to do:

- Create `/var/log/traefik` sub directory:

```sh
mkdir -p /var/log/traefik
```

- Create `/etc/logrotate.d/traefik`:

```sh
/var/log/traefik/traefik-access.log {
  daily
  rotate 5
  compress
  dateext
  dateformat -%Y%m%d-%s
  missingok
  notifempty
  postrotate
    docker kill --signal="USR1" traefik
  endscript
}
```

- Insert in `/etc/cronttab` directives for rotating:
  
```sh
## Traefik Access.log rotation
0 0 * * * root /usr/sbin/logrotate -f /etc/logrotate.d/traefik
```

## Usefull commands

```sh

echo $(htpasswd -nB user) | sed -e s/\\$/\\$\\$/g
echo $(htpasswd -nB usuario) | sed -e s/\\$/\\$\\$/g

htpasswd -nB user
htpasswd -nB usuario

openssl req -newkey rsa:2048 -x509 -nodes -keyout "0a0f2746.nip.io.key" -new -out "0a0f2746.nip.io.crt" -subj "/CN=*.0a0f2746.nip.io" -reqexts SAN -extensions SAN -config <(cat /etc/ssl/openssl.cnf <(printf "[SAN]\nsubjectAltName=DNS:*.%s, DNS:%s" "0a0f2746.nip.io" "0a0f2746.nip.io")) -sha256 -days 3650

cat "0a0f2746.nip.io.crt" "0a0f2746.nip.io.key" | tee "0a0f2746.nip.io.pem"

openssl x509 -in 0a0f2746.nip.io.crt -text -noout

netstat -tulpn | grep LISTEN | grep -E '0.0.0.0:*' | grep -E '0 0.0.0.0|0 10.15.39.70'

docker run -it --rm -d -p 88:80 --name webtest nginx
```


