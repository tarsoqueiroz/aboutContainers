# Dockerfile

## 
##  Construção da imagem com diretivas de segurança para o Apache HTTPd
##  Versão: 2026/01/20

# Utiliza a imagem do registro interno informada
FROM image-registry.openshift-image-registry.svc:5000/tarsodemo/httpd-24:latest

# Define a versão da imagem via argumento de build (injetado pelo BuildConfig)
ARG IMAGE_VERSION=1.0
LABEL version=$IMAGE_VERSION \
      description="HTTPD com Hardening de Segurança"

# Copia o arquivo de segurança para o diretório de configurações do Apache
COPY security.conf /etc/httpd/conf.d/security.conf

# Garante permissões adequadas (o OpenShift roda com usuários aleatórios/não-root)
USER root
RUN chown -R 1001:0 /etc/httpd/conf.d/security.conf && \
    chmod 644 /etc/httpd/conf.d/security.conf

# Retorna para o usuário padrão da imagem (geralmente 1001)
USER 1001

CMD ["run-httpd"]
