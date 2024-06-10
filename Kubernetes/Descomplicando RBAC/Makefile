CLUSTER_NAME=rbac
APP_NAMESPACE=default

.PHONY: env
# env
env:
	@echo "*** Showing environment variables...\n"
	@echo "CLUSTER_NAME      = $(CLUSTER_NAME)"
	@echo "APP_NAMESPACE     = $(APP_NAMESPACE)"

.PHONY: build
# build
build:
	@echo "*** Creating a temporary data path...\n"
	@mkdir temp.data

	@echo "*** Creating a kind cluster...\n"
	@kind create cluster --config resources/rbac-cluster.yaml --name ${CLUSTER_NAME}

.PHONY: destroy
# destroy
destroy:
	@echo "*** Deleting the kind cluster...\n"
	@kind delete cluster --name $(CLUSTER_NAME)

	@echo "*** Removing temporary data...\n"
	@rm -rf temp.data

.PHONY: deploy
# deploy
deploy:
	@echo "*** Deploying sample application...\n"
	@TRAEFIK_NAMESPACE=$(TRAEFIK_NAMESPACE) \
	APP_NAMESPACE=$(APP_NAMESPACE) \
	./deploy.sh
	@echo "\nTry: http://localhost\n"
