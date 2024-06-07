CLUSTER_NAME=traefik
TRAEFIK_NAMESPACE=traefik
APP_NAMESPACE=default

.PHONY: environment
# env show environment variables
environment:
	@echo "CLUSTER_NAME      = ${CLUSTER_NAME}"
	@echo "TRAEFIK_NAMESPACE = ${TRAEFIK_NAMESPACE}"
	@echo "APP_NAMESPACE     = ${APP_NAMESPACE}"

.PHONY: build
# build creates a kind cluster
build:
	@kind create cluster --config kind-config.yaml --name ${CLUSTER_NAME}

.PHONY: install
# deploy deploys traefik and the app
install:
	@TRAEFIK_NAMESPACE=$(TRAEFIK_NAMESPACE) \
	APP_NAMESPACE=$(APP_NAMESPACE) \
	./install.sh

.PHONY: deploy
# deploy deploys traefik and the app
deploy:
	@TRAEFIK_NAMESPACE=$(TRAEFIK_NAMESPACE) \
	APP_NAMESPACE=$(APP_NAMESPACE) \
	./deploy.sh

.PHONY: destroy
# destroy deletes the kind cluster
destroy:
	@kind delete cluster --name $(CLUSTER_NAME)
