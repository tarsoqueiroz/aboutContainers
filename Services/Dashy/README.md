# Dashy: The Ultimate Homepage for your Homelab

> `https://dashy.to/`

```sh
docker run -d \
  -p 8080:80 \
  -v ~/my-conf.yml:/app/public/conf.yml \
  --name my-dashboard \
  --restart=always \
  lissy93/dashy:latest
```
