# MetalLB and Reverse Proxy

## Using NGINX

- [CONFIGURANDO O NGINX COMO PROXY REVERSO NO DOCKER](https://conzatech.com/configurando-o-nginx-como-proxy-reverso-no-docker/)
- Github [nginx-proxy / nginx-proxy](https://github.com/nginx-proxy/nginx-proxy)
- [Automated Nginx Reverse Proxy for Docker](http://jasonwilder.com/blog/2014/03/25/automated-nginx-reverse-proxy-for-docker/)

## Using HAProxy

- [HAProxy as a static reverse proxy for Docker containers](http://oskarhane.com/haproxy-as-a-static-reverse-proxy-for-docker-containers/)
- [HAProxy Documentation Converter](https://cbonte.github.io/haproxy-dconv/)

```Shell
figlet 'Run HAProxy with Docker'
echo 'https://www.haproxy.com/blog/how-to-run-haproxy-with-docker/'
docker network ls
docker network inspect mynetwork

docker run -d --name web1 --net mynetwork jmalloc/echo-server:latest
docker run -d --name web2 --net mynetwork jmalloc/echo-server:latest
docker run -d --name web3 --net mynetwork jmalloc/echo-server:latest
docker ps -a

docker inspect web1 | grep IPAddress
docker inspect web2 | grep IPAddress
docker inspect web3 | grep IPAddress
cat haproxy.cfg

kubectl get services -o wide

docker rm haproxy -f
docker run -d --name haproxy --net host -v $(pwd):/usr/local/etc/haproxy:ro haproxytech/haproxy-alpine:2.4
```
