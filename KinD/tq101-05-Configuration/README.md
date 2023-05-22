# tq101 05 - Configuration

## Creating using config file

```sh
kind create cluster --config <CONFIG_FILE.yaml>
```

## Cluster name

- [Cluster name config file](./cluster-name.yaml)

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: app-1-cluster
```

## API Server

- [API Server config file](./api-server.yaml)

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  # WARNING: It is _strongly_ recommended that you keep this the default
  # (127.0.0.1) for security reasons. However it is possible to change this.
  apiServerAddress: "127.0.0.1"
  # By default the API server listens on a random open port.
  # You may choose a specific port but probably don't need to in most cases.
  # Using a random port makes it easier to spin up multiple clusters.
  apiServerPort: 6443
```

## Pod and Service subnet

- [Pod and Service subnet config file]()

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4

name: podsvcsubnet

networking:
  podSubnet: "10.244.0.0/16"
  serviceSubnet: "10.96.0.0/12"
```

> **NOTE 1:** By default, kind uses 10.244.0.0/16 pod subnet for IPv4 and fd00:10:244::/56 pod subnet for IPv6.

> **NOTE 2:** By default, kind uses 10.96.0.0/16 service subnet for IPv4 and fd00:10:96::/112 service subnet for IPv6.

## Nodes

- [Nodes](./nodes.yaml)

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
# One control plane node and three "workers".
#
# While these will not add more real compute capacity and
# have limited isolation, this can be useful for testing
# rolling updates etc.
#
# The API-server and other control plane components will be
# on the control-plane node.
#
# You probably don't need this unless you are testing Kubernetes itself.
nodes:
- role: control-plane
- role: worker
- role: worker
- role: worker
```

## Node Kubernetes version

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  image: kindest/node:v1.16.4@sha256:b91a2c2317a000f3a783489dfb755064177dbc3a0b2f4147d50f04825d016f55
- role: worker
  image: kindest/node:v1.16.4@sha256:b91a2c2317a000f3a783489dfb755064177dbc3a0b2f4147d50f04825d016f55
```

> You can set a specific Kubernetes version by setting the node’s container image. You can find available image tags on the [releases page](https://github.com/kubernetes-sigs/kind/releases).

## Extra mounts

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  # add a mount from /path/to/my/files on the host to /files on the node
  extraMounts:
  - hostPath: /path/to/my/files
    containerPath: /files
  #
  # add an additional mount leveraging *all* of the config fields
  #
  # generally you only need the two fields above ...
  #
  - hostPath: /path/to/my/other-files/
    containerPath: /other-files
    # optional: if set, the mount is read-only.
    # default false
    readOnly: true
    # optional: if set, the mount needs SELinux relabeling.
    # default false
    selinuxRelabel: false
    # optional: set propagation mode (None, HostToContainer or Bidirectional)
    # see https://kubernetes.io/docs/concepts/storage/volumes/#mount-propagation
    # default None
    #
    # WARNING: You very likely do not need this field.
    #
    # This field controls propagation of *additional* mounts created
    # *at runtime* underneath this mount.
    #
    # On MacOS with Docker Desktop, if the mount is from macOS and not the
    # docker desktop VM, you cannot use this field. You can use it for
    # mounts to the linux VM.
    propagation: None
```

Try this with `extramount.yaml`:

```sh
docker ps

## Attach to control plane node
docker exec -it extramount-control-plane /bin/bash

## Inside container execute:
ls -lah /
cd /Data/
ls -lah
cat /etc/debian_version > ./test2.txt 
cat ./test2.txt 
exit

## Back to prompt, execute these:
ll vol.data/extramount.controlplane/test2.txt 
cat vol.data/extramount.controlplane/test2.txt 

## Attach to worker node
docker exec -it extramount-worker /bin/bash

## Inside container execute:
ls -lah / ## No /Data found
exit

## Attach to worker2 node
docker exec -it extramount-worker2 /bin/bash

## Inside container execute:
ls -lah /
ls -lah /Data/
cat /etc/debian_version > /Data/Debian.version
ls -lah /Data/
cat /Data/Debian.version 
exit

## Back to prompt, execute these:
ll vol.data/extramount.worker2/Debian.version
cat vol.data/extramount.worker2/Debian.version
```

## That's all folks

Seeya!!!
