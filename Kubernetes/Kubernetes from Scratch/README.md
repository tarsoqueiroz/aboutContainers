# Mastering Kubernetes From Scratch (Hands-On)

## About

> [Udemy: Mastering Kubernetes From Scratch (Hands-On)](https://www.udemy.com/course/kubernetes-cloud-native)

**Cloud Native Application Development Series**

This comprehensive course is designed for senior and staff-level engineers who want to elevate their Kubernetes expertise and confidently apply it to real-world production scenarios. Through a combination of in-depth lectures and hands-on exercises, you will gain a masterful understanding of core Kubernetes concepts and develop the practical skills needed to:

- Design and deploy highly scalable and resilient applications.
- Optimize resource utilization and manage production clusters efficiently.
- Implement automated deployments and rollbacks for streamlined workflows.
- Ensure application high availability and robust monitoring.
- Leverage cloud platforms like Google Cloud Platform for seamless Kubernetes deployment and management.

Boost Your Career in the Booming Field of Container Orchestration:

Mastering Kubernetes is a significant asset in today's IT landscape. This course empowers you to:

- Become a valuable asset to your team and organization.
- Stay ahead of the curve in the rapidly evolving field of containerization.
- Command a higher salary in the high-demand Kubernetes job market.

Course Curriculum:

- Kubernetes Architecture: Deep dive into the core components and their roles (api-server, etcd, controller, scheduler).
- Hands-on Cluster Creation: Learn to create Kubernetes clusters using tools like kind.
- Pod Management: Explore deploying workloads, accessing logs, containers, APIs, and debugging techniques.
- Deployment Strategies: Master managing application revisions, rollbacks, and implementing different deployment strategies.
- Service Discovery and Load Balancing: Understand different service types (ClusterIP, NodePort, LoadBalancer).
- Resource Management with Namespaces: Learn to logically separate workloads and resources.
- Health Monitoring and Liveness/Readiness Probes: Implement strategies for application health checks and monitoring.
- Configuration Management with ConfigMaps and Secrets: Discover secure ways to manage configurations and secrets.
- Stateful Applications with Persistent Volumes and StatefulSets: Utilize persistent storage for stateful applications and explore running MongoDB in Kubernetes.
- Dynamic Scaling with Horizontal Pod Autoscaler: Scale applications based on CPU and memory metrics.
- Efficient Traffic Management with Ingress: Create routing rules for efficient traffic management.
- Kubernetes on Cloud Platform (Google Kubernetes Engine / GKE): Explore deploying and managing clusters on a cloud platform.

Enroll Now and Master Kubernetes for Production!

Take the next step in your Kubernetes journey and unlock its power to build, deploy, and manage your applications with confidence. This course provides the hands-on experience and in-depth knowledge you need to become a Kubernetes powerhouse in your production environment.

Who's this course for:

- Software engineers who want to understand Kubernetes deeply
- Developers who want to deploy applications to Kubernetes
- DevOps and platform engineers who want hands on experience

## Introduction

Course Materials:

Please find the resources which might be helpful for you.

- The Source Code for this course is available here: [Github: kubernetes-course](https://github.com/vinsguru/kubernetes-course).
- Kubernetes commands we discuss in this course is here: [PDF k8s-commands](./resources/k8s-commands.pdf).

## Kubernetes Clusters

- Kubernetes cluster components: [PDF k8s-commands](./resources/k8s-commands.pdf) page 2
- [Kubernetes Documentation](https://kubernetes.io/docs/home/)

Tools:

- kubectl
- kind

Starting with Kind K8s cluster:

```sh
kind create cluster --config ./resources/Github-kubernetes-course/sec01-cluster-creation/01-cluster.yaml  -n k8sfromscratch
kubectl cluster-info 
kubectl get nodes -o wide
kubectl version --output=yaml
docker ps -as
docker exec -it k8sfromscratch-control-plane bash
```

Inside Control Pane container:

```sh
ls -alhF
cd /etc/kubernetes/manifests/
ls -alhF
ps -aux
exit
```

Go to worker container:

```sh
docker ps -as
docker exec -it k8sfromscratch-worker bash
```

Inside Worker container:

```sh
ls -alhF
ps -aux
exit
```

Clear cluster:

```sh
kind delete cluster -n k8sfromscratch
docker ps -as
kubectl version --output=yaml
```

## Pod

- [Kubernetes doc: Pod](https://kubernetes.io/docs/concepts/workloads/pods/)

### Pod template

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: meu-pod-exemplo
  namespace: default
  labels:
    app: minha-aplicacao
    version: "1.0"
    environment: production
  annotations:
    description: "Pod de exemplo com principais elementos"
    maintainer: "equipe-dev@empresa.com"
    kubernetes.io/change-cause: "Deploy da versão 1.0"
spec:
  # Contêineres principais do Pod
  containers:
  - name: aplicacao-principal
    image: nginx:1.25
    imagePullPolicy: IfNotPresent
    
    # Portas que o contêiner expõe
    ports:
    - name: http
      containerPort: 80
      protocol: TCP
    - name: https
      containerPort: 443
      protocol: TCP
    
    # Variáveis de ambiente
    env:
    - name: ENVIRONMENT
      value: "production"
    - name: LOG_LEVEL
      value: "INFO"
    - name: CONFIG_PATH
      value: "/etc/config"
    
    # Variáveis de ambiente a partir de ConfigMap/Secret
    envFrom:
    - configMapRef:
        name: meu-configmap
    - secretRef:
        name: meu-secret
    
    # Comando e argumentos de inicialização
    command: ["nginx"]
    args: ["-g", "daemon off;"]
    
    # Recursos computacionais
    resources:
      requests:
        memory: "128Mi"
        cpu: "250m"
      limits:
        memory: "256Mi"
        cpu: "500m"
    
    # Probes de saúde
    livenessProbe:
      httpGet:
        path: /health
        port: 80
      initialDelaySeconds: 30
      periodSeconds: 10
      timeoutSeconds: 5
      failureThreshold: 3
    
    readinessProbe:
      httpGet:
        path: /ready
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 5
      timeoutSeconds: 3
      failureThreshold: 1
    
    startupProbe:
      httpGet:
        path: /startup
        port: 80
      initialDelaySeconds: 10
      periodSeconds: 10
      failureThreshold: 30
    
    # Configurações de segurança
    securityContext:
      runAsNonRoot: true
      runAsUser: 1000
      runAsGroup: 1000
      allowPrivilegeEscalation: false
      capabilities:
        drop:
        - ALL
        add:
        - NET_BIND_SERVICE
    
    # Montagem de volumes
    volumeMounts:
    - name: config-volume
      mountPath: /etc/nginx/conf.d
      readOnly: true
    - name: data-volume
      mountPath: /var/log/nginx
    
    # Política de término
    lifecycle:
      preStop:
        exec:
          command: ["/bin/sh", "-c", "nginx -s quit; while killall -0 nginx; do sleep 1; done"]

  # Contêineres de inicialização
  initContainers:
  - name: init-db
    image: busybox:1.35
    command: ['sh', '-c', 'echo "Inicializando banco de dados..." && sleep 10']
    resources:
      requests:
        memory: "64Mi"
        cpu: "100m"
  
  # Volumes
  volumes:
  - name: config-volume
    configMap:
      name: nginx-config
      items:
      - key: nginx.conf
        path: nginx.conf
  - name: data-volume
    emptyDir: {}
  
  # Configurações de rede
  hostNetwork: false
  hostPID: false
  hostIPC: false
  dnsPolicy: ClusterFirst
  dnsConfig:
    nameservers:
    - 8.8.8.8
    searches:
    - default.svc.cluster.local
    - svc.cluster.local
    - cluster.local
    options:
    - name: ndots
      value: "2"
  
  # Configurações de segurança do Pod
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    runAsGroup: 1000
    fsGroup: 2000
    seccompProfile:
      type: RuntimeDefault
  
  # Afinidade e anti-afinidade
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: kubernetes.io/arch
            operator: In
            values:
            - amd64
            - arm64
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 1
        preference:
          matchExpressions:
          - key: disktype
            operator: In
            values:
            - ssd
    
    podAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: app
            operator: In
            values:
            - cache
        topologyKey: kubernetes.io/hostname
    
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchExpressions:
            - key: app
              operator: In
              values:
              - minha-aplicacao
          topologyKey: kubernetes.io/hostname
  
  # Tolerations para nós com taints
  tolerations:
  - key: "node-type"
    operator: "Equal"
    value: "gpu"
    effect: "NoSchedule"
  - key: "spot-instance"
    operator: "Exists"
    effect: "NoExecute"
  
  # Prioridade da classe do Pod
  priorityClassName: high-priority
  
  # Restart policy
  restartPolicy: Always
  
  # Service Account
  serviceAccountName: minha-service-account
  
  # Tempo para término gracioso
  terminationGracePeriodSeconds: 60

# Status (gerado automaticamente pelo Kubernetes)
status:
  phase: Pending
  conditions: []
  hostIP: ""
  podIP: ""
  startTime: null
```

#### Minimalist Pod template

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-basico
  labels:
    app: nginx
spec:
  containers:
  - name: nginx-container
    image: nginx:alpine
    ports:
    - containerPort: 80

    # Comando e argumentos de inicialização
    command: ["nginx"]
    args: ["-g", "daemon off;"]
    
    # Recursos computacionais
    resources:
      requests:
        memory: "128Mi"
        cpu: "250m"
      limits:
        memory: "256Mi"
        cpu: "500m"
```

### Pod lab

```sh
# Create K8s ckyster
kind create cluster --config ./manifests/sec01/0101-cluster.yaml 
kubectl get nodes -o wide

# create first pod
kubectl get pod

# terminal alternative
watch -t -x kubectl get pod
kubectl create -f ./manifests/sec02/0201-simple-pod.yaml 
kubectl get pod

# delete first pod
kubectl delete -f ./manifests/sec02/0201-simple-pod.yaml 
kubectl get pod

# describe a pod
kubectl create -f ./manifests/sec02/0201-simple-pod.yaml 
kubectl describe pod
kubectl delete -f ./manifests/sec02/0201-simple-pod.yaml 

# create and apply
kubectl create -f ./manifests/sec02/0201b-simple-pod.yaml # ngins v1.14
kubectl describe pod my-podv
kubectl apply -f ./manifests/sec02/0201b-simple-pod.yaml  # ngins v1.15
kubectl describe pod my-podv
kubectl delete -f ./manifests/sec02/0201b-simple-pod.yaml

# image Pull Backoff
kubectl create -f ./manifests/sec02/0201c-simple-pod.yaml 
kubectl describe pod my-podv 
kubectl delete -f ./manifests/sec02/0201c-simple-pod.yaml

# image Crash Loop Backoff
kubectl create -f ./manifests/sec02/0202-failing-pod.yaml 
kubectl describe pod my-pod 
kubectl delete -f ./manifests/sec02/0202-failing-pod.yaml 
```

- Kubernetes Pod status: [PDF k8s-commands](./resources/k8s-commands.pdf) page 6

```sh
# pod labels
kubectl create -f ./manifests/sec02/0203-multiple-pods.yaml 
kubectl describe pod
kubectl get pod
kubectl get pod pod-1
kubectl describe pod pod-3
kubectl get pod --show-labels 
kubectl get pod -l dept=dept-1
kubectl get pod -l dept=dept-1 --show-labels
kubectl get pod -l team=team-a --show-labels
kubectl get pod -l team!=team-a --show-labels
kubectl get pod -l dept=dept-1,team=team-a --show-labels
kubectl get pod -l dept=dept-2,team=team-a --show-labels
kubectl get pod -l dept=dept-2,team=team-b --show-labels
kubectl delete -f ./manifests/sec02/0203-multiple-pods.yaml 

# formating output
kubectl get pods
kubectl get pods -o wide
kubectl get pods pod-1 -o yaml
kubectl delete -f ./manifests/sec02/0203-multiple-pods.yaml

# deleting a pod
kubectl get pods
kubectl create -f ./manifests/sec02/0203-multiple-pods.yaml
kubectl get pods
kubectl delete pod pod-2
kubectl delete pod/pod-3
kubectl get pods
kubectl describe pod/pod-1
kubectl delete -f ./manifests/sec02/0203-multiple-pods.yaml

# port forward
kubectl get pods
kubectl create -f ./manifests/sec02/0204-pod-port.yaml 
kubectl get pods
kubectl port-forward my-pod 80:80
kubectl port-forward my-pod 8888:80
####### At browse try: `http://localhost:8888/`
####### CTRL + C
####### At browse try: `http://localhost:8888/`
kubectl delete -f ./manifests/sec02/0204-pod-port.yaml 

# restartPolicy
kubectl create -f ./manifests/sec02/0205-restart-policy.yaml # without restartPolicy
kubectl get pod -o yaml
kubectl delete -f ./manifests/sec02/0205-restart-policy.yaml 
kubectl create -f ./manifests/sec02/0205-restart-policy.yaml # with restartPolicy: Never
kubectl delete -f ./manifests/sec02/0205-restart-policy.yaml 

# pod args and logs
kubectl create -f ./manifests/sec02/0206-pod-args.yaml 
kubectl logs my-pod 
kubectl delete -f ./manifests/sec02/0206-pod-args.yaml 

# pod args shell form
kubectl create -f ./manifests/sec02/0207-pod-shell-args.yaml 
kubectl logs my-pod 
kubectl delete -f ./manifests/sec02/0207-pod-shell-args.yaml 

# termination grace period
kubectl create -f ./manifests/sec02/0208-pod-termination-grace-period.yaml  ## without terminationGracePeriodSeconds
kubectl delete -f ./manifests/sec02/0208-pod-termination-grace-period.yaml  ## without terminationGracePeriodSeconds
kubectl create -f ./manifests/sec02/0208-pod-termination-grace-period.yaml  ## with terminationGracePeriodSeconds
kubectl delete -f ./manifests/sec02/0208-pod-termination-grace-period.yaml  ## with terminationGracePeriodSeconds

# pod command
kubectl create -f ./manifests/sec02/0209-pod-command.yaml  ## with args
kubectl logs pods/my-pod 
kubectl delete -f ./manifests/sec02/0209-pod-command.yaml  ## with args
kubectl create -f ./manifests/sec02/0209-pod-command.yaml  ## with command
kubectl logs pods/my-pod 
kubectl delete -f ./manifests/sec02/0209-pod-command.yaml  ## with command

# environment variables
kubectl create -f ./manifests/sec02/0210-pod-env.yaml 
kubectl logs pods/my-pod 
kubectl delete -f ./manifests/sec02/0210-pod-env.yaml 

# exploring pod container
kubectl create -f ./manifests/sec02/0201-simple-pod.yaml 
kubectl get pods
kubectl exec -it my-pod bash
kubectl exec -it my-pod -- bash
####### inside pod
root@my-pod:/# history 
    1  echo Inside pod my-pod
    2  ls -alhF
    3  curl
    4  curl localhost
    5  exit
####### back to terminal
kubectl get pods
kubectl delete -f ./manifests/sec02/0201-simple-pod.yaml 

# multi container pod
kubectl create -f ./manifests/sec02/0211-multi-containers.yaml 
kubectl get pod
kubectl get pod -o wide
kubectl logs my-pod 
kubectl logs my-pod -c nginx-1
kubectl logs my-pod -c util
kubectl exec -it my-pod -- bash
####### inside pod (mypod:nginx-1)
root@my-pod:/# history 
    1  hostname
    2  ls -alhF
    3  exit
####### back to terminal
kubectl exec -it my-pod -c util -- bash
####### inside pod (mypod:util)
root@my-pod:/# history 
    1  hostname
    2  ls -alhF
    3  curl localhost
    4  exit
####### back to terminal
kubectl delete -f ./manifests/sec02/0211-multi-containers.yaml 
```

### ASSIGNMENT for Pod

Please try to create this pod and analyze why it is failing. Please fix if possible.

```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: pod-assignment
    spec:
      restartPolicy: OnFailure
      containers:
      - name: assignment
        image: vinsdocker/k8s-pod-assignment
```

```sh
# assignment
kubectl create -f ./manifests/sec02/0212-pod-assignment.yaml 
kubectl logs pods/pod-assignment
### result
You need to do the followings to make this work
  1. Set an environment variable 'NUMBER' with the value 5
  2. Pass the arg 'MY_ARG'
###
kubectl delete -f ./manifests/sec02/0212-pod-assignment.yaml 

# assignment solution
kubectl create -f ./manifests/sec02/0213-pod-assignment-solution.yaml 
kubectl logs pods/pod-assignment 
### result
Good Job!!
###
kubectl delete -f ./manifests/sec02/0213-pod-assignment-solution.yaml
```

## ReplicaSet

- [Kubernetes doc: ReplicaSet](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/)

### ReplicaSet lab

```sh
# creating replicaset
kubectl get pods
kubectl get replicaset
kubectl get rs
kubectl get all
kubectl create -f ./manifests/sec03/0301-simple-rs.yaml 
kubectl get pod --show-labels
kubectl delete pod/my-rs-pxm9c 
kubectl delete pod --all
kubectl delete -f ./manifests/sec03/0301-simple-rs.yaml

# replicaset labels
kubectl apply -f ./manifests/sec03/0301-simple-rs.yaml # label my-app-1
kubectl apply -f ./manifests/sec03/0301-simple-rs.yaml # label my-app and team
kubectl get pod --show-labels
kubectl delete -f ./manifests/sec03/0301-simple-rs.yaml

# replicaset with existing pod
kubectl create -f ./manifests/sec03/0302-multiple-pods.yaml 
kubectl create -f ./manifests/sec03/0303-existing-pod-manager.yaml 
kubectl get pod --show-labels
kubectl delete pod/pod-1
kubectl get pod --show-labels
kubectl delete pod/pod-3
kubectl get pod --show-labels
kubectl delete -f ./manifests/sec03/0303-existing-pod-manager.yaml

# multiple replicaset
kubectl create -f ./manifests/sec03/0304-multiple-rs.yaml # without my-rs-2 
kubectl create -f ./manifests/sec03/0304-multiple-rs.yaml # with my-rs-2
kubectl get pod --show-labels
kubectl delete pod/my-rs-1-2dmcs
kubectl delete pod/my-rs-2-5ckcr
kubectl delete -f ./manifests/sec03/0304-multiple-rs.yaml

# describing replicaset
kubectl create -f ./manifests/sec03/0304-multiple-rs.yaml # with my-rs-2
kubectl describe rs/my-rs-1
kubectl delete pod/my-rs-1-tvl6x 
kubectl describe rs/my-rs-1
```

## Deployment

- [Kubernetes doc: Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)

### Deployment template

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: meu-deployment-exemplo
  namespace: default
  labels:
    app: minha-aplicacao
    version: "1.0.0"
    environment: production
  annotations:
    deployment.kubernetes.io/revision: "1"
    description: "Deployment de exemplo com principais elementos"
    maintainer: "devops-team@company.com"
spec:
  # Réplicas e estratégia de implantação
  replicas: 3
  minReadySeconds: 10
  progressDeadlineSeconds: 600
  
  # Seletor para identificar os Pods gerenciados
  selector:
    matchLabels:
      app: minha-aplicacao
      tier: backend
  
  # Estratégia de atualização
  strategy:
    type: RollingUpdate  # Alternativas: Recreate
    rollingUpdate:
      maxSurge: 1        # Máximo de pods acima do desejado durante atualização
      maxUnavailable: 0  # Máximo de pods indisponíveis durante atualização
  
  # Template do Pod
  template:
    metadata:
      labels:
        app: minha-aplicacao
        tier: backend
        version: "1.0.0"
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "9090"
        prometheus.io/path: "/metrics"
    
    spec:
      # Contêineres principais
      containers:
      - name: aplicacao
        image: minha-aplicacao:1.0.0
        imagePullPolicy: IfNotPresent
        
        # Portas
        ports:
        - name: http
          containerPort: 8080
          protocol: TCP
        - name: metrics
          containerPort: 9090
          protocol: TCP
        
        # Variáveis de ambiente
        env:
        - name: ENVIRONMENT
          value: "production"
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: connection-string
        - name: CONFIG_MAP_VALUE
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: api-endpoint
        
        # Recursos
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        
        # Probes de saúde
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
            scheme: HTTP
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          successThreshold: 1
          failureThreshold: 3
        
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
            scheme: HTTP
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 3
          successThreshold: 1
          failureThreshold: 1
        
        startupProbe:
          httpGet:
            path: /startup
            port: 8080
            scheme: HTTP
          initialDelaySeconds: 10
          periodSeconds: 10
          failureThreshold: 30
        
        # Segurança
        securityContext:
          runAsNonRoot: true
          runAsUser: 1000
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          capabilities:
            drop:
            - ALL
        
        # Montagem de volumes
        volumeMounts:
        - name: config-volume
          mountPath: /etc/config
          readOnly: true
        - name: temporary-storage
          mountPath: /tmp
        
        # Lifecycle hooks
        lifecycle:
          postStart:
            exec:
              command: ["/bin/sh", "-c", "echo 'Container started' > /tmp/startup.log"]
          preStop:
            exec:
              command: ["/bin/sh", "-c", "sleep 10; echo 'Graceful shutdown'"]
      
      # Contêineres sidecar (opcional)
      - name: sidecar-logger
        image: busybox:1.35
        command: ['sh', '-c', 'tail -f /var/log/app.log']
        volumeMounts:
        - name: log-volume
          mountPath: /var/log
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
      
      # Contêineres de inicialização
      initContainers:
      - name: init-migrations
        image: minha-aplicacao:1.0.0
        command: ['sh', '-c', 'npm run db:migrate']
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: connection-string
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
        volumeMounts:
        - name: config-volume
          mountPath: /etc/config
          readOnly: true
      
      # Volumes
      volumes:
      - name: config-volume
        configMap:
          name: app-config
          items:
          - key: application.properties
            path: application.properties
      
      - name: log-volume
        emptyDir: {}
      
      - name: temporary-storage
        emptyDir:
          medium: Memory
          sizeLimit: "1Gi"
      
      # Configurações de segurança do Pod
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        runAsGroup: 1000
        fsGroup: 2000
        seccompProfile:
          type: RuntimeDefault
      
      # Afinidade e agendamento
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: kubernetes.io/arch
                operator: In
                values:
                - amd64
                - arm64
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 1
            preference:
              matchExpressions:
              - key: disktype
                operator: In
                values:
                - ssd
        
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - minha-aplicacao
              topologyKey: kubernetes.io/hostname
      
      # Tolerations
      tolerations:
      - key: "node-type"
        operator: "Equal"
        value: "gpu"
        effect: "NoSchedule"
      - key: "spot-instance"
        operator: "Exists"
        effect: "NoExecute"
        tolerationSeconds: 3600
      
      # Service Account
      serviceAccountName: minha-service-account
      
      # Prioridade
      priorityClassName: high-priority
      
      # Tempo para término gracioso
      terminationGracePeriodSeconds: 60
      
      # DNS configurações
      dnsConfig:
        options:
        - name: ndots
          value: "2"
        - name: edns0

# Status (gerado automaticamente pelo Kubernetes)
status:
  observedGeneration: 1
  replicas: 3
  updatedReplicas: 3
  readyReplicas: 3
  availableReplicas: 3
  conditions:
  - type: Available
    status: "True"
    lastUpdateTime: "2023-10-01T10:00:00Z"
    lastTransitionTime: "2023-10-01T10:00:00Z"
    reason: MinimumReplicasAvailable
    message: Deployment has minimum availability.
  - type: Progressing
    status: "True"
    lastUpdateTime: "2023-10-01T10:00:00Z"
    lastTransitionTime: "2023-10-01T10:00:00Z"
    reason: NewReplicaSetAvailable
    message: ReplicaSet "meu-deployment-exemplo-12345" has successfully progressed.
```

#### Minimalist Deployment template

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment-minimo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: minha-app
  template:
    metadata:
      labels:
        app: minha-app
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
```

### Deployment lab

```sh
# demo, create & apply
kubectl create -f ./manifests/sec04/0401-simple-deploy.yaml 
kubectl get deploy
kubectl create -f ./manifests/sec04/0401-simple-deploy.yaml 
kubectl delete -f ./manifests/sec04/0401-simple-deploy.yaml 
kubectl get all
kubectl apply -f ./manifests/sec04/0401-simple-deploy.yaml 
kubectl apply -f ./manifests/sec04/0401-simple-deploy.yaml 
kubectl apply -f ./manifests/sec04/0401-simple-deploy.yaml 

# log & port forward
kubectl describe deployments.apps my-deploy 
kubectl exec -it deployments/my-deploy -- bash
####### inside pod
ls -alhF
exit
#######
kubectl port-forward deployments/my-deploy 8080:80
####### at browser: http://localhost:8080/
kubectl delete -f ./manifests/sec04/0401-simple-deploy.yaml

# deploy revisions
kubectl apply -f ./manifests/sec04/0402-deploy-rs.yaml # version :v1 & 3 replicas (revision 1)
kubectl apply -f ./manifests/sec04/0402-deploy-rs.yaml # 2 replicas (revision 1)
kubectl apply -f ./manifests/sec04/0402-deploy-rs.yaml # version :v2 (revision 2)
kubectl apply -f ./manifests/sec04/0402-deploy-rs.yaml # env BUNNY  (revision 3)
kubectl apply -f ./manifests/sec04/0402-deploy-rs.yaml # 4 replicas (revision 3)
kubectl delete -f ./manifests/sec04/0402-deploy-rs.yaml

# rollout history
kubectl apply -f ./manifests/sec04/0403-deploy-rollout.yaml  # without annotations
kubectl port-forward deployments/order-service-deploy 8080:80
####### on browser: http://localhost:8080 you'll see v1
kubectl apply -f ./manifests/sec04/0403-deploy-rollout.yaml  # without annotations & version :v2
kubectl port-forward deployments/order-service-deploy 8080:80
####### on browser: http://localhost:8080 you'll see v2
kubectl rollout history deployment order-service-deploy 
kubectl apply -f ./manifests/sec04/0403-deploy-rollout.yaml  # without annotations & version :v3
kubectl rollout history deployment order-service-deploy 
kubectl port-forward deployments/order-service-deploy 8080:80
####### on browser: http://localhost:8080  you'll see v3
kubectl rollout undo deployment order-service-deploy 
kubectl port-forward deployments/order-service-deploy 8080:80
####### on browser: http://localhost:8080  you'll see v2
kubectl rollout history deployment order-service-deploy 
kubectl rollout undo deployment order-service-deploy 
kubectl port-forward deployments/order-service-deploy 8080:80
####### on browser: http://localhost:8080  you'll see v3
kubectl rollout history deployment order-service-deploy 
kubectl delete -f ./manifests/sec04/0403-deploy-rollout.yaml
kubectl rollout history deployment order-service-deploy 

# rollback
kubectl apply -f ./manifests/sec04/0403-deploy-rollout.yaml # with annotation v1
kubectl rollout history deployment order-service-deploy 
kubectl port-forward deployments/order-service-deploy 8080:80 
####### on browser: http://localhost:8080 v1
kubectl apply -f ./manifests/sec04/0403-deploy-rollout.yaml # with annotation v2
kubectl rollout history deployment order-service-deploy 
kubectl port-forward deployments/order-service-deploy 8080:80 
####### on browser: http://localhost:8080 v2
kubectl apply -f ./manifests/sec04/0403-deploy-rollout.yaml # with annotation v3
kubectl rollout history deployment order-service-deploy 
kubectl port-forward deployments/order-service-deploy 8080:80 
####### on browser: http://localhost:8080 v3
kubectl rollout undo deployment order-service-deploy 
kubectl rollout history deployment order-service-deploy 
kubectl rollout undo deployment order-service-deploy --to-revision=1
kubectl rollout history deployment order-service-deploy 
kubectl port-forward deployments/order-service-deploy 8080:80 
####### on browser: http://localhost:8080 v1
kubectl rollout undo deployment order-service-deploy --to-revision=3
kubectl port-forward deployments/order-service-deploy 8080:80 
####### on browser: http://localhost:8080 v3
kubectl delete -f ./manifests/sec04/0403-deploy-rollout.yaml

# checking rollout changes
kubectl apply -f ./manifests/sec04/0403-deploy-rollout.yaml # with annotation v1
kubectl apply -f ./manifests/sec04/0403-deploy-rollout.yaml # with annotation v2
kubectl apply -f ./manifests/sec04/0403-deploy-rollout.yaml # with annotation v3
kubectl rollout history deployment order-service-deploy 
kubectl rollout undo deployment order-service-deploy
kubectl rollout history deployment order-service-deploy 
kubectl rollout undo deployment order-service-deploy --to-revision=3 
kubectl rollout history deployment order-service-deploy 
kubectl rollout undo deployment order-service-deploy --to-revision=1
kubectl rollout history deployment order-service-deploy 
kubectl rollout history deployment --revision=5
kubectl rollout history deployment --revision=6
kubectl rollout history deployment --revision=3
kubectl delete -f ./manifests/sec04/0403-deploy-rollout.yaml

# min ready seconds
kubectl apply -f ./manifests/sec04/0404-min-ready-seconds.yaml 
kubectl delete -f ./manifests/sec04/0404-min-ready-seconds.yaml 

# deployment strategy
# recreate strategy
kubectl apply -f ./manifests/sec04/0405-deploy-recreate.yaml # v1
kubectl apply -f ./manifests/sec04/0405-deploy-recreate.yaml # v2
kubectl delete -f ./manifests/sec04/0405-deploy-recreate.yaml
# rolling update strategy - maxsurge
kubectl apply -f ./manifests/sec04/0406-deploy-max-surge.yaml # v1 maxsurge 100%
kubectl apply -f ./manifests/sec04/0406-deploy-max-surge.yaml # v2 maxsurge 100%
kubectl apply -f ./manifests/sec04/0406-deploy-max-surge.yaml # v3 maxsurge 1
kubectl delete -f ./manifests/sec04/0406-deploy-max-surge.yaml
# rolling update strategy - maxunavailable
 2188  kubectl apply -f ./manifests/sec04/0407-deploy-max-unavailable.yaml # v1 maxunavailable 1
 2189  kubectl apply -f ./manifests/sec04/0407-deploy-max-unavailable.yaml # v2 maxunavailable 1
 2190  kubectl delete -f ./manifests/sec04/0407-deploy-max-unavailable.yaml
```

### ASSIGNMENT for Deployment

```sh
kubectl apply -f ./manifests/sec04/0408-redis-deployment.yaml 
kubectl get pod -o wide
kubectl apply -f ./manifests/sec04/0409-app-assignment.yaml 
```

## Service

- [Kubernetes doc: Service](https://kubernetes.io/docs/concepts/services-networking/service/)

### Service template

```yaml
apiVersion: v1
kind: Service
metadata:
  name: meu-service-exemplo
  namespace: default
  labels:
    app: minha-aplicacao
    tier: backend
    version: "1.0"
  annotations:
    description: "Service de exemplo com principais elementos"
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
    cloud.google.com/load-balancer-type: "Internal"
spec:
  # Tipo do Service (ClusterIP, NodePort, LoadBalancer, ExternalName)
  type: ClusterIP
  
  # Seletor para encontrar os Pods (opcional para Services do tipo ExternalName)
  selector:
    app: minha-aplicacao
    tier: backend
  
  # Portas do Service
  ports:
  - name: http
    protocol: TCP
    port: 80              # Porta do Service
    targetPort: 8080      # Porta do Pod
    nodePort: 30080       # Usado apenas para NodePort (30000-32767)
  
  - name: https
    protocol: TCP
    port: 443
    targetPort: 8443
  
  - name: metrics
    protocol: TCP
    port: 9090
    targetPort: 9090
  
  # Configurações específicas por cloud provider
  externalTrafficPolicy: Cluster  # ou Local
  internalTrafficPolicy: Cluster  # ou Local
  
  # IP do Service (se necessário fixar)
  clusterIP: 10.0.0.100  # Opcional - normalmente atribuído automaticamente
  
  # IPs externos (para acesso direto)
  externalIPs:
  - 203.0.113.100
  - 203.0.113.101
  
  # Para Services do tipo LoadBalancer
  loadBalancerIP: 203.0.113.200  # IP específico do Load Balancer
  loadBalancerSourceRanges:
  - 130.211.0.0/22
  - 35.191.0.0/16
  
  # Configuração de session affinity
  sessionAffinity: ClientIP  # ou None
  sessionAffinityConfig:
    clientIP:
      timeoutSeconds: 10800  # 3 horas
  
  # Health check (para alguns providers)
  healthCheckNodePort: 32123  # Para type: LoadBalancer com externalTrafficPolicy: Local
  
  # Para Services do tipo ExternalName
  # externalName: meu.database.example.com

# Status (gerado automaticamente pelo Kubernetes)
status:
  loadBalancer:
    ingress:
    - ip: 203.0.113.200
    - hostname: lb-example.us-east-1.elb.amazonaws.com
```

#### Examples Service template

- Service ClusterIP (Default - Internal Access)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: service-clusterip
spec:
  type: ClusterIP
  selector:
    app: minha-app
  ports:
  - port: 80
    targetPort: 8080
```

- Service NodePort (Externa Access by NodePort)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: service-nodeport
spec:
  type: NodePort
  selector:
    app: minha-app
  ports:
  - port: 80
    targetPort: 8080
    nodePort: 30080
```

- Service LoadBalancer (Cloud Provider)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: service-loadbalancer
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
spec:
  type: LoadBalancer
  selector:
    app: minha-app
  ports:
  - port: 80
    targetPort: 8080
  loadBalancerIP: 203.0.113.100
  externalTrafficPolicy: Local
```

- Service ExternalName (Proxy for External Service)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: service-external
spec:
  type: ExternalName
  externalName: api.externo.com
```

- Service Headless (Without ClusterIP)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: service-headless
spec:
  clusterIP: None  # Headless service
  selector:
    app: stateful-app
  ports:
  - port: 80
    targetPort: 8080
```

### Service lab

```sh
# demo
kubectl apply -f ./manifests/sec05/0501-simple-deploy.yaml  # replicas 3 
kubectl apply -f ./manifests/sec05/0502-simple-service.yaml 
kubectl describe service nginx 
kubectl get pod -o wide
watch -t -n 1 -x kubectl describe service nginx # second term
kubectl delete pod my-deploy-687d598649-hd7mg 
kubectl apply -f ./manifests/sec05/0501-simple-deploy.yaml # replicas 5
kubectl apply -f ./manifests/sec05/0501-simple-deploy.yaml # replicas 1
kubectl get deployments.apps 
kubectl delete deployments.apps my-deploy 
kubectl apply -f ./manifests/sec05/0501-simple-deploy.yaml # replicas 3
kubectl delete -f ./manifests/sec05/0502-simple-service.yaml -f ./manifests/sec05/0501-simple-deploy.yaml

# loadbalancing demo
kubectl apply -f ./manifests/sec05/0503-svc-load-balancing.yaml 
kubectl exec -it demo-pod -- bash
################ inside pod
root@demo-pod:/# curl my-app
################
kubectl delete -f ./manifests/sec05/0503-svc-load-balancing.yaml 

# redis assignment with service
kubectl apply -f ./manifests/sec05/0504-app-assignment.yaml 
kubectl port-forward deployments/assignment 8080
####### at browser: localhost:8080
kubectl delete -f ./manifests/sec05/0504-app-assignment.yaml 

# nodeport demo
kubectl apply -f ./manifests/sec05/0505-nodeport-service.yaml 
curl localhost:30001
kubectl exec -it demo-pod -- bash
################ inside pod
root@demo-pod:/# curl my-app:80
root@demo-pod:/# curl my-app:80
root@demo-pod:/# curl my-app:80
root@demo-pod:/# curl my-app:80
exit
################
kubectl apply -f ./manifests/sec05/0505-nodeport-service.yaml 

# rolling update with service
kubectl apply -f ./manifests/sec05/0506-rolling-update-demo.yaml # v1
####### on another term
kubectl exec -it demo-pod -- bash
################ inside pod
curl my-app
for i in {1..5000}; do curl -s http://my-app | grep -o "<title>[^<]*" | tail -c+8; done
exit
################
####### on main term
kubectl apply -f ./manifests/sec05/0506-rolling-update-demo.yaml # v2
kubectl apply -f ./manifests/sec05/0506-rolling-update-demo.yaml # v3
kubectl rollout undo deployment order-service-deploy 
kubectl delete -f ./manifests/sec05/0506-rolling-update-demo.yaml
```

## Namespace

- [Kubernetes doc: Namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)

### Namespace lab

```sh
# basic
kubectl get namespaces 
kubectl get ns
kubectl get pod
kubectl create ns dev
kubectl create namespace qa
kubectl get ns
kubectl get pod -n dev
kubectl get pod -n qa
kubectl create -f ./manifests/sec02/0201-simple-pod.yaml -n dev
kubectl get pod
kubectl get pod -n dev
kubectl delete -f ./manifests/sec02/0201-simple-pod.yaml
kubectl delete -f ./manifests/sec02/0201-simple-pod.yaml -n dev
kubectl delete ns qa
kubectl get ns

# kube-system ns
kubectl get pod
kubectl get pod -n kube-system
kubectl get pod -n kube-system -o wide

# ns deploy demo
kubectl get ns
kubectl create ns dev
kubectl apply -f ./manifests/sec05/0506-rolling-update-demo.yaml -n qa
kubectl create ns qa
kubectl apply -f ./manifests/sec05/0506-rolling-update-demo.yaml -n qa # v3
kubectl apply -f ./manifests/sec05/0506-rolling-update-demo.yaml -n dev # v2
kubectl get all -n qa
kubectl get all -n dev
kubectl port-forward -n qa services/my-app 8080:80
kubectl port-forward svc/my-app 8080:80 -n qa     # browser: localhost:8080
kubectl port-forward svc/my-app 8080:80 -n dev    # browser: localhost:8080
kubectl get all -A -o wide
kubectl delete ns dev
kubectl delete ns qa
kubectl get all -A -o wide
```

### Namespace via Metadata

```yaml
metadata:
  name: <resource_name>
  namespace: <namespace_name>
```

## Probes

## ConfigMap & Secret

## Persistent Volume & StatefulSet

## Horizontal Pod Autoscaler (HPA)

## Ingress

## Role Play

## That's all

... folks!!!
