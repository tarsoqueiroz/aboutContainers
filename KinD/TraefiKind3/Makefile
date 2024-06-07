CLUSTER_NAME=traefik
TRAEFIK_NAMESPACE=traefik
APP_NAMESPACE=default

.PHONY: env
# env
env:
	@echo "*** Showing environment variables...\n"
	@echo "CLUSTER_NAME      = $(CLUSTER_NAME)"
	@echo "TRAEFIK_NAMESPACE = $(TRAEFIK_NAMESPACE)"
	@echo "APP_NAMESPACE     = $(APP_NAMESPACE)"

.PHONY: build
# build
build:
	@echo "*** Creating a kind cluster...\n"
	@kind create cluster --config kind-config.yaml --name ${CLUSTER_NAME}

.PHONY: install
# install
install:
	@echo "*** Installing Traefik components...\n"
	@TRAEFIK_NAMESPACE=$(TRAEFIK_NAMESPACE) \
	APP_NAMESPACE=$(APP_NAMESPACE) \
	./install.sh
	@echo "\nTry: http://localhost:8080\n"

.PHONY: deploy
# deploy
deploy:
	@echo "*** Deploying sample application...\n"
	@TRAEFIK_NAMESPACE=$(TRAEFIK_NAMESPACE) \
	APP_NAMESPACE=$(APP_NAMESPACE) \
	./deploy.sh
	@echo "\nTry: http://localhost\n"

.PHONY: destroy
# destroy
destroy:
	@echo "*** Deleting the kind cluster...\n"
	@kind delete cluster --name $(CLUSTER_NAME)
