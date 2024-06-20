CLUSTER_NAME=traefik
TRAEFIK_NAMESPACE=traefik
APP_NAMESPACE=default
NIP_HOSTNAME=0a0f122c

.PHONY: env
# env
env:
	@echo "*** Showing environment variables...\n"
	@echo "CLUSTER_NAME      = $(CLUSTER_NAME)"
	@echo "TRAEFIK_NAMESPACE = $(TRAEFIK_NAMESPACE)"
	@echo "APP_NAMESPACE     = $(APP_NAMESPACE)"
	@echo "NIP_HOSTNAME      = $(NIP_HOSTNAME)"
	@echo ""

.PHONY: build
# build
build:
	@echo "*** Creating a kind cluster...\n"
	@kind create cluster --config ./resources/kind-config.yaml --name ${CLUSTER_NAME}

.PHONY: install
# install
install:
	@echo "*** Installing Traefik components...\n"
	@TRAEFIK_NAMESPACE=$(TRAEFIK_NAMESPACE) \
	APP_NAMESPACE=$(APP_NAMESPACE) \
	./install.sh
	@echo "\nTry: http://localhost:8888\n"

.PHONY: deploy
# deploy
deploy:
	@echo "*** Deploying sample application...\n"
	@TRAEFIK_NAMESPACE=$(TRAEFIK_NAMESPACE) \
	APP_NAMESPACE=$(APP_NAMESPACE) \
	./deploy.sh
	@echo "\nTry: http://localhost\n"

.PHONY: deploytiny1
# deploy
deploytiny1:
	@echo "*** Deploying tinyweb1 application...\n"
	@TRAEFIK_NAMESPACE=$(TRAEFIK_NAMESPACE) \
	APP_NAMESPACE=$(APP_NAMESPACE) \
	./deploytiny1.sh
	@echo "\nTry: http://tiny1.0a0f122c.nip.io:80\n"

.PHONY: destroy
# destroy
destroy:
	@echo "*** Deleting the kind cluster...\n"
	@kind delete cluster --name $(CLUSTER_NAME)
