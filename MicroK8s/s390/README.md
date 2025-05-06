# MicroK8s on S390x

```bash0
tarso@bastion:~$ ssh tarso@0a0f0fa0.nip.io

tarso@0a0f0fa0.nip.io's password: 
Welcome to Ubuntu 24.04.2 LTS (GNU/Linux 6.8.0-55-generic s390x)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of ter 06 mai 2025 09:45:55 -03

  System load: 0.0                Memory usage: 8%   Processes:       175
  Usage of /:  10.5% of 24.94GB   Swap usage:   0%   Users logged in: 0

...

```

## Getting started

Fist steps on MicroK8s:

```bash
# show versions
snap info microk8s

# install specific version (1.31/edge)
snap install microk8s --classic --channel=1.31/edge

# show info about installed version
snap list microk8s

# completely remove MicroK8s
snap remove --purge microk8s
```