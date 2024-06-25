CLUSTER_NAME=traefik
TRAEFIK_NAMESPACE=traefik
APP_NAMESPACE=default
APP_HTTPBIN=httpbin
APP_HTTPBINHIGH=httpbinhigh
APP_TWI1=twi1
APP_TWI2=twi2
APP_TWI3=twi3
NIP_HOSTNAME=0a0f122c

.PHONY: env
# env
env:
	@echo "*** Showing environment variables...\n"
	@echo "CLUSTER_NAME      = $(CLUSTER_NAME)"
	@echo "TRAEFIK_NAMESPACE = $(TRAEFIK_NAMESPACE)"
	@echo "APP_NAMESPACE     = $(APP_NAMESPACE)"
	@echo "APP_HTTPBIN       = $(APP_HTTPBIN)"
	@echo "APP_HTTPBINHIGH   = $(APP_HTTPBINHIGH)"
	@echo "APP_TWI1          = $(APP_TWI1)"
	@echo "APP_TWI2          = $(APP_TWI2)"
	@echo "APP_TWI3          = $(APP_TWI3)"
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
	./traefik/traefik_install.sh
	@echo "\nTry: http://0a0f122c.nip.io:8888\n"

.PHONY: deploy
# deploy
deploy:
	@echo "*** Deploying sample application...\n"
	@APP_NAMESPACE=$(APP_HTTPBIN) envsubst < ./resources/httpbin.yaml | kubectl apply -f -
	@echo "\nTry: http://0a0f122c.nip.io\n"

.PHONY: undeploy
# undeploy
undeploy:
	@echo "*** Deploying sample application...\n"
	@APP_NAMESPACE=$(APP_HTTPBIN) envsubst < ./resources/httpbin.yaml | kubectl delete -f -

.PHONY: deployhigh
# deployhigh
deployhigh:
	@echo "*** Deploying HTTPBin sample application...\n"
	@APP_NAMESPACE=$(APP_HTTPBINHIGH) envsubst < ./resources/httpbinhigh.yaml | kubectl apply -f -
	@echo "\nTry: http://high.0a0f122c.nip.io:8080\n"

.PHONY: undeployhigh
# undeployhigh
undeployhigh:
	@echo "*** unDeploying HTTPBin sample application...\n"
	@APP_NAMESPACE=$(APP_HTTPBINHIGH) envsubst < ./resources/httpbinhigh.yaml | kubectl delete -f -

.PHONY: deploytwi1
# deploytwi1
deploytwi1:
	@echo "*** Deploying tinywebinfo 1.0 application...\n"
	@APP_NAMESPACE=$(APP_TWI1) envsubst < ./resources/twi1.yaml | kubectl apply -f -
	@echo "\nTry: http://twi1.0a0f122c.nip.io\n"

.PHONY: undeploytwi1
# undeploytwi1
undeploytwi1:
	@echo "*** unDeploying tinywebinfo 1.0 application...\n"
	@APP_NAMESPACE=$(APP_TWI1) envsubst < ./resources/twi1.yaml | kubectl delete -f -

.PHONY: deploytwi2
# deploytwi2
deploytwi2:
	@echo "*** Deploying tinywebinfo 2.0 application...\n"
	@APP_NAMESPACE=$(APP_TWI2) envsubst < ./resources/twi2.yaml | kubectl apply -f -
	@echo "\nTry: http://twi2.0a0f122c.nip.io:8080\n"

.PHONY: undeploytwi2
# undeploytwi2
undeploytwi2:
	@echo "*** unDeploying tinywebinfo 2.0 application...\n"
	@APP_NAMESPACE=$(APP_TWI2) envsubst < ./resources/twi2.yaml | kubectl delete -f -

.PHONY: deploytwi3
# deploytwi3
deploytwi3:
	@echo "*** Deploying tinywebinfo 3.0 application...\n"
	@APP_NAMESPACE=$(APP_TWI3) envsubst < ./resources/twi3.yaml | kubectl apply -f -
	@echo "\nTry: http://twi3.0a0f122c.nip.io:9090\n"

.PHONY: undeploytwi3
# undeploytwi3
undeploytwi3:
	@echo "*** unDeploying tinywebinfo 3.0 application...\n"
	@APP_NAMESPACE=$(APP_TWI3) envsubst < ./resources/twi3.yaml | kubectl delete -f -

.PHONY: destroy
# destroy
destroy:
	@echo "*** Deleting the kind cluster...\n"
	@kind delete cluster --name $(CLUSTER_NAME)
