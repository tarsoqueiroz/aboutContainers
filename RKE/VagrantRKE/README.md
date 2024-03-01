# Local Kubernetes Cluster Setup with Vagrant and RKE

> `https://github.com/LukeMwila/local-kubernetes-setup-with-rke-and-vagrant`
>
> [Install/Upgrade Rancher on a Kubernetes Cluster](https://ranchermanager.docs.rancher.com/getting-started/installation-and-upgrade/install-upgrade-on-a-kubernetes-cluster)
>
> [Setting up a High-availability K3s Kubernetes Cluster for Rancher](https://ranchermanager.docs.rancher.com/how-to-guides/new-user-guides/kubernetes-cluster-setup/k3s-for-rancher)
>
> [Setting up Infrastructure for a High Availability K3s Kubernetes Cluster](https://ranchermanager.docs.rancher.com/how-to-guides/new-user-guides/infrastructure-setup/ha-k3s-kubernetes-cluster)
>
> [Setting up Rancher on Your Local Machine with an RKE Provisioned Cluster](https://www.suse.com/c/rancher_blog/setting-up-rancher-on-your-local-machine-with-an-rke-provisioned-cluster/)
>
> [Example Cluster.ymls](https://rke.docs.rancher.com/example-yamls)

## RKE cluster install

```sh
git clone https://github.com/LukeMwila/local-kubernetes-setup-with-rke-and-vagrant.git

vagrant up

ssh-keygen -f "~/.ssh/known_hosts" -R "<node IP>"
ssh-copy-id root@<node IP>

rke up --config <CLUSTER-CONF.yaml>

export KUBECONFIG=kube_config_<CLUSTER-CONF>.yaml

kubectl get nodes -o wide

kubectl get pods -A -o wide
```

## Rancher install

Rancher helm chart repo

```sh
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
helm repo list
helm repo update

helm search repo rancher
```

Create namespace for Rancher

```sh
kubectl create namespace cattle-system
kubectl get namespace
```

Install `cert-manager`

```sh
# If you have installed the CRDs manually instead of with the `--set installCRDs=true` option added 
# to your Helm install command, you should upgrade your CRD resources before upgrading the Helm chart
# Get version to be used at https://github.com/cert-manager/cert-manager/releases
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.4/cert-manager.crds.yaml

# Add the Jetstack Helm repository
helm repo add jetstack https://charts.jetstack.io
helm repo list
helm repo update

helm search repo cert-manager

# Install the cert-manager Helm chart
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace

kubectl get pods --namespace cert-manager
```

Install Rancher

```sh
helm repo list

helm install rancher rancher-stable/rancher \
  --namespace cattle-system \
  --set hostname=rancher.c0a8380d.nip.io \
  --set bootstrapPassword=adminrancher

# If you provided your own bootstrap password during installation, 
# browse to https://rancher.c0a8380d.nip.io to get started.
#
# If this is the first time you installed Rancher, get started by 
# running this command and clicking the URL it generates:

echo https://rancher.c0a8380d.nip.io/dashboard/?setup=$(kubectl get secret --namespace cattle-system bootstrap-secret -o go-template='{{.data.bootstrapPassword|base64decode}}')

# To get just the bootstrap password on its own, run:

kubectl get secret --namespace cattle-system bootstrap-secret -o go-template='{{.data.bootstrapPassword|base64decode}}{{ "\n" }}'

```
