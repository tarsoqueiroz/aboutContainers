# Web3270

Commands used for deploy and reference:

```sh
docker run -d --name=web3270                            \
           -p 8443:9443                                 \
           -v /home/tarso/Projects/web3270:/config      \
           -v /home/tarso/Projects/web3270/certs:/certs \
           --restart unless-stopped                     \
           tarsoqueiroz/web3270

docker exec -it web3270 sh
```
