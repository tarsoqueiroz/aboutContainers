# KUBERNETES OPERATOR EM GO - Criando o primeiro operador para Kubernetes com GoLang

## Sobre

> [KUBERNETES OPERATOR EM GO - Criando o primeiro operador para Kubernetes com GoLang](https://www.youtube.com/watch?v=TnG6r4861Z4)

Neste vídeo, vamos aprender a criar um operador customizado no Kubernetes usando Go! Desde a instalação das ferramentas até a implementação do operador no Minikube.

Capitulos:

- 00:00 Intro
- 00:50 Instalação e configuração das ferramentas
- 02:50 Iniciando operator com kubebuilder
- 05:45 Alterando/Criando código do nosso operator
- 11:40 Instando e rodando operator
- 12:50 Testando operator

Ferramentas utilizadas:

- [MINIKUBE - Cria um cluster Kubernetes local: Instalação do Minikube](https://minikube.sigs.k8s.io/docs/start/?arch=%2Fmacos%2Farm64%2Fstable%2Fbinary+download)
- [DOCKER - Gerencia contêineres para o desenvolvimento local: Instalação do Docker](https://docs.docker.com/engine/install/)
- [KUBERNETES - Sistema para orquestrar contêineres: Documentação do Kubernetes](https://kubernetes.io/docs/setup/)
- [GOLANG - Linguagem usada para desenvolver o operador: Instalação do Go](https://www.youtube.com/watch?v=eJq_D9at6ec)
- [KUBEBUILDER - Framework para construir operadores Kubernetes: Instalação do Kubebuilder](https://book.kubebuilder.io/quick-start)
- [KIND - Cria clusters Kubernetes usando Docker, útil para testes: Documentação do Kind](https://kind.sigs.k8s.io/docs/user/quick-start)

## Code

```bash
## diretorio de trabalho
mkdir my-operator
cd my-operator/

## inicializando o projeto
kubebuilder init --domain example.com --repo my-operator

## criando a api
kubebuilder create api --group app --version v1apha1 --kind MyApp

> INFO Create Resource [y/n] 
y
> INFO Create Controller [y/n] 
y
```

Editar `./api/v1alpha1/myapp_types.go`:

```go
// MyAppSpec defines the desired state of MyApp.
type MyAppSpec struct {
  Replicas int32 `json:"replicas"`
}

// MyAppStatus defines the observed state of MyApp.
type MyAppStatus struct {
  AvailableReplicas int32 `json:"availableReplicas"`
}
```

Editar `./internal/controller/myapp_controller.go`:

```go
// Parte 1

// MyAppReconciler reconciles a MyApp object
type MyAppReconciler struct {
  client.Client

  log logr.Logger

  Scheme *runtime.Scheme
}

// Parte 

func (r *MyAppReconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
  _ = logf.FromContext(ctx)

  // TODO(user): your logic here
  myApp := &appv1apha1.MyApp{}

  err := r.Get(ctx, req.NamespacedName, myApp)
  if err != nil {
    r.log.Error(err, msg:"error trying to reconcile object, namespacedName=%s", req.NamespacedName)
    return ctrl.Result{}, err
  }

  r.log.Info(msg:"Reconciling MyApp: name=%s, apiVersion=%s, kind=%s", 
    myApp.Name,
    myApp.APIVersion,
    myApp.Kind
  )

  return ctrl.Result{}, nil
}
```

```bash
make generate

make manifests

make install

kubectl get crds

make run
```

Recurso `myapp.yaml`:

- [`myapp.yaml`](./myapp.yaml)

```bash
kubectl apply -f myapp.yaml
```

