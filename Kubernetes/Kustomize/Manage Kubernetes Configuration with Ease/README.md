# Kustomize Mastery: Manage Kubernetes Configuration with Ease

## About

> [`https://www.udemy.com/course/kustomize-mastery-manage-kubernetes-configuration-with-ease`](https://www.udemy.com/course/kustomize-mastery-manage-kubernetes-configuration-with-ease)

Everything you need to know about managing real world kubernetes configurations with Kustomize.

- [**Kustomize**: Introduction to Kustomize](https://kubectl.docs.kubernetes.io/guides/introduction/kustomize/)
- [**Github**: Udemy Course Kustomize Mastery](https://github.com/galonge/udemy-kustomize-mastery)

### In this course

...you will:

- **Understand** how Kustomize works.
- **Understand** how to use kustomize to manage kubernetes manifests for multiple environments from scratch.
- **Apply** kustomize to existing kubernetes configurations manifests.
- **Assess** and decide when to use Kustomize and when the use case isn’t suitable.
- **Understand** various ways to set up Kustomize and pros and cons of each.

## Quick start

### What is Kustomize?

O **Kustomize** é uma ferramenta nativa do Kubernetes que permite customizar configurações de aplicações sem a necessidade de templates. Ele funciona com arquivos YAML comuns, aplicando "camadas" de personalização sobre uma base. Isso significa que você pode ter um arquivo de configuração base e criar variações para diferentes ambientes (produção, staging, etc.), mantendo a clareza e a rastreabilidade das mudanças.

### Kustomize Hands-on - Get Ready

Now, let us get our hands dirty a bit and see this thing we have been talking about in action.

The goal of this section is to get you started on the benefits of kustomize with the least setup required.

So, we are NOT going to install kubectl or kustomize yet, instead, we will be using a cloud service called "Killer Koda". This provides us with a playground for kubernetes with kubectl already installed.

To get started,

- Head over to (Killer Koda) - `https://killercoda.com/playgrounds/scenario/kubernetes`  to provision a demo playground (**update - May, 2023:** killa koda now requires you to use your github account or gmail)
- Confirm kubectl and kustomize is installed and versions with the following command: 

```sh
kubectl version --short
```

The output should look something like the following:

```sh
Client Version: v1.25.2
Kustomize Version: v4.5.7
```

As long as you have a kubectl client version higher than v1.14, you should have kustomize and be ready to proceed.

### Kind for Local Kubernetes cluster

```sh
kind create cluster --config ./manifests/k8scluster.yaml -n k8stomize

kind get clusters 

kubectl get nodes -o wide
```

### Hands-on Live

#### Deploy WordPress with tradicional manifests

```sh
kubectl apply -f manifests/wordpress-hol/example.v1/

kubectl get pods -o wide

kubectl get svc -o wide

kubectl port-forward svc/wordpress --address 0.0.0.0 8888:80
```

Browse to `http://localhost:8888` and you'll see the WordPress app.

Clean-up the instalation.

```sh
kubectl delete -f manifests/wordpress-hol/example.v1/

kubectl get pods
```

#### Deploy WordPress with base manifests

```sh
kubectl create ns wordpress-v1

kubectl apply -k manifests/wordpress-hol/kustomize/base/ -n wordpress-v1

kubectl get pod -A

kubectl get pod -n wordpress-v1

kubectl describe pod wordpress-7bfbd4c494-ztzjk -n wordpress-v1

kubectl kustomize manifests/wordpress-hol/kustomize/base/

kubectl kustomize manifests/wordpress-hol/kustomize/v2/

kubectl apply -k manifests/wordpress-hol/kustomize/v2/ -n wordpress-v2

kubectl get pod -A

kubectl get pod -n wordpress-v2

kubectl get svc -n wordpress-v2

kubectl port-forward svc/wordpress -n wordpress-v2 8888:80

kubectl kustomize manifests/wordpress-hol/kustomize/v3/

kubectl create ns wordpress-v3

kubectl apply -k manifests/wordpress-hol/kustomize/v3/ -n wordpress-v3

kubectl get pods -n wordpress-v3

kubectl get svc -n wordpress-v3
```

Browse to `http://localhost:8910` and you'll see the WordPress app.

Let's go to configure DB connection:

- **Database Name**: `wordpress`
- **Username**: `root`
- **Password**: `password`
- **Database Host**: `10.96.198.92` (*from svc of last command*)
- **Table Prefix**: `wp_`

```sh
kubectl port-forward svc/wordpress -n wordpress-v3 --address 0.0.0.0 8910:80

kubectl delete ns wordpress-v1

kubectl delete ns wordpress-v2

kubectl delete ns wordpress-v3
```

## Introduction

### Getting Course Resources

All the examples and assignment files are in a single code repository on [GitHub](https://github.com/galonge/udemy-kustomize-mastery).

Each folder represents a single lecture section (but not all lectures have a folder, as not all need code).

You should clone [this repo](https://github.com/galonge/udemy-kustomize-mastery) to a folder on your desktop or somewhere on your computer.

Clone the GitHub repository:

```sh
git clone https://github.com/galonge/udemy-kustomize-mastery
```

If you're rather new to GitHub, you can download the GUI to make it very easy to push/pull code at `https://desktop.github.com/` for Mac and Windows.

A great alternative Git client is `https://www.gitkraken.com/`.

We won't use git much in this course, but knowing the basics of pulling code, committing code, and pushing updates could be helpful.

Join our online learning community on slack:

- [`https://join.slack.com/t/kustomizemastery/shared_invite/zt-1majqkdwj-3wtm9l0RV3JchDv_cnPQPQ`](https://join.slack.com/t/kustomizemastery/shared_invite/zt-1majqkdwj-3wtm9l0RV3JchDv_cnPQPQ)

Subscribe to my YouTube channel to stay updated on new resources about Kubernetes, DevOps and SRE:

- [`https://www.youtube.com/@galonge`](https://www.youtube.com/@galonge)

> **PS:** For some sections with code samples in the repo, the section numbers may not match directly due to the order in which the videos are uploaded. Please use the section title in such cases. 

### Installing Kustomize

- [Install Kustomize](https://kubectl.docs.kubernetes.io/installation/kustomize/)

## The Kustomization file

- [The Kustomization File](https://kubectl.docs.kubernetes.io/references/kustomize/kustomization/)
- [Kustomize Docs: ConfigMapGenerator usage via `kustomization.yaml`](https://kubectl.docs.kubernetes.io/references/kustomize/builtins/#_configmapgenerator_)
- [Kustomize Docs: SecretGenerator usage via `kustomization.yaml`](https://kubectl.docs.kubernetes.io/references/kustomize/builtins/#_secretgenerator_)
- [Kubernetes Types of Secret](https://kubernetes.io/docs/concepts/configuration/secret/#secret-types)
- [Hashicorp URL Format](https://github.com/hashicorp/go-getter#url-format)
- [Kustomize Docs: resources](https://kubectl.docs.kubernetes.io/references/kustomize/kustomization/resource/)
- [Kustomize Docs: namespace](https://kubectl.docs.kubernetes.io/references/kustomize/kustomization/namespace/)
- [Kustomize Docs: labels](https://kubectl.docs.kubernetes.io/references/kustomize/kustomization/labels/)
- [Kustomize Docs: commonAnnotations](https://kubectl.docs.kubernetes.io/references/kustomize/kustomization/commonannotations/)
- [Kustomize Docs: commonLabels](https://kubectl.docs.kubernetes.io/references/kustomize/kustomization/commonannotations/)

### Transformers

```sh
# @manifests/wordpress-s3/v1
kubectl kustomize . > result-v1.yaml
```

### Generators

```sh
# @manifests/wordpress-s3/v112
kubectl create ns v112
kubectl config get-contexts
kubectl get ns
kubectl config set-context --current --namespace=v112
kubectl get ns
kubectl config get-contexts
kubectl get pods
kubectl kustomize .
ll
kubectl kustomize .
kubectl kustomize . > result-v112.yaml
kubectl apply -k .
kubectl get pods
kubectl logs pods/v112-mysql-6969b67746-4z8m9 
kubectl get cm
kubectl describe cm/v112-mysql-config 
kubectl get pods
kubectl logs pods/v112-mysql-6969b67746-4z8m9 
kubectl describe pods/v112-mysql-6969b67746-4z8m9 
kubectl delete -k .
kubectl delete -k . > result-v112.yaml 
kubectl kustomize . > result-v112.yaml
kubectl apply -k .
kubectl get pods
kubectl exec -it v112-mysql-6969b67746-km92k 
kubectl exec -it v112-mysql-6969b67746-km92k  -- sh
kubectl get pods
kubectl logs pods/v112-mysql-6969b67746-km92k 
kubectl get pods
kubectl get pods -w
kubectl get cm
kubectl get pods -w
kubectl delete -k .
kubectl apply -k .
kubectl get pods 
kubectl get pods -w
kubectl delete -k .
```

### Secret Generator

```sh
# @manifests/wordpress-s3/v113
kubectl kustomize .
kubectl kustomize . > result-v113.yaml
echo "d29yZHByZXNz" | base64 -d
echo "YWRtaW4=" | base64 -d
kubectl config get-contexts 
kubectl apply -k .
kubectl get pods -w
kubectl describe secrets v113-mysql-secret 
kubectl delete -k .
```
### Kubernetes Resources Abbreviations

Some kubernetes resources abbreviations:

- all
- certificatesigningrequests (aka 'csr')
- componentstatuses (aka 'cs')
- configmaps (aka 'cm')
- daemonsets (aka 'ds')
- deployments (aka 'deploy')
- endpoints (aka 'ep')
- events (aka 'ev')
- horizontalpodautoscalers (aka 'hpa')
- ingresses (aka 'ing')
- limitranges (aka 'limits')
- namespaces (aka 'ns')
- networkpolicies
- nodes (aka 'no')
- persistentvolumeclaims (aka 'pvc')
- persistentvolumes (aka 'pv')
- pods (aka 'po')
- poddisruptionbudgets (aka 'pdb')
- podsecuritypolicies (aka 'psp')
- replicasets (aka 'rs')
- replicationcontrollers (aka 'rc')
- resourcequotas (aka 'quota')
- serviceaccounts (aka 'sa')
- services (aka 'svc')

## Working with Patches

- [Kustomize docs: patchesStrategicMerge](https://kubectl.docs.kubernetes.io/references/kustomize/kustomization/patchesstrategicmerge/)
- [Directives: Strategic Merge Patch](https://github.com/kubernetes/community/blob/master/contributors/devel/sig-api-machinery/strategic-merge-patch.md)
- [Server-Side Apply](https://kubernetes.io/docs/reference/using-api/server-side-apply/)
- [JSON 6902 standard: JavaScript Object Notation (JSON) Patch](https://www.rfc-editor.org/rfc/rfc6902)
- [Kustomize docs: patchesJson6902](https://kubectl.docs.kubernetes.io/references/kustomize/kustomization/patchesjson6902/)

### Strategic Merge

Files on `resources / Github_udemy-kustomize-mastery / code-samples / 4-patches / wordpress / kustomize / lec-18-strategic-merge`.

### Patches - JSON6902

Files on `resources / Github_udemy-kustomize-mastery / code-samples / 4-patches / wordpress / kustomize / lec-19-json-6902`.

## Working with Custom Resource Definitions (CRDs)

Files on `resources / Github_udemy-kustomize-mastery / code-samples / 5-crds / wordpress / kustomize`.

## Managing Multiple Environments with Overlays

Files on `resources / Github_udemy-kustomize-mastery / code-samples / 6-multiple-envs`.

- [**Online Boutique** is a cloud-first microservices demo application](https://github.com/GoogleCloudPlatform/microservices-demo)

## Reusing Kustomize Configurations

Files on `resources / Github_udemy-kustomize-mastery / code-samples / 7-re-using-configurations / wordpress / kustomize`.

- [Kustomize docs: components](https://kubectl.docs.kubernetes.io/references/kustomize/kustomization/components/)
- [Kustomize docs: Kustomize components guide](https://kubectl.docs.kubernetes.io/guides/config_management/components/)
- [Kustomize docs: replacements](https://kubectl.docs.kubernetes.io/references/kustomize/kustomization/replacements/)
- [Wordpress: Docker Official Image](https://hub.docker.com/_/wordpress)

## Continuous Integration and Deployment Pipelines (CI/CD)

- [Configuring OpenID Connect in Google Cloud Platform](https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-google-cloud-platform)
- [How does the GCP Workload Identity Federation work with Github Provider?](https://medium.com/google-cloud/how-does-the-gcp-workload-identity-federation-work-with-github-provider-a9397efd7158)
- [Quickstart for GitHub Actions](https://docs.github.com/en/actions/get-started/quickstart)
- [GCP Workload Identity Federeation](https://cloud.google.com/iam/docs/workload-identity-federation?_ga=2.246785924.-164099188.1663652343#mapping)

## Conclusion

- [Join Slack](https://join.slack.com/t/devopswithgeorge/shared_invite/zt-1majqkdwj-3wtm9l0RV3JchDv_cnPQPQ)

## Additional Kustomize Contents

Files on `resources / Github_udemy-kustomize-mastery / code-samples / k-cli / wordpress / kustomize`.

- [Commands: Reference for the kustomize CLI](https://kubectl.docs.kubernetes.io/references/kustomize/cmd/)

Files on `resources / Github_udemy-kustomize-mastery / code-samples / using-helmcharts`.

- [Kustomize docs: helmCharts](https://kubectl.docs.kubernetes.io/references/kustomize/kustomization/helmcharts/)
- [Helm Install](https://helm.sh/docs/intro/install/)
- [`Artifacthub.io`: Find, install and publish Cloud Native packages](https://artifacthub.io/)

## That's

...all folks!!!
