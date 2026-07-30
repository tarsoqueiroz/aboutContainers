#!/usr/bin/env bash
set -eo pipefail

echo "🚀 Iniciando build com Buildah..."

# Cria container temporário a partir de Alpine
ctr=$(buildah from docker.io/library/alpine:latest)

# Instala o pacote jq dentro do container
buildah run $ctr -- apk add --no-cache jq

# Configura variável de ambiente e comando padrão
buildah config --env FERRAMENTA=jq $ctr
buildah config --cmd '["jq", "--version"]' $ctr

# Gera a imagem OCI final
buildah commit $ctr imagem-buildah:v1

# Remove o container temporário
buildah rm $ctr

echo "✅ Imagem imagem-buildah:v1 criada com sucesso!"
