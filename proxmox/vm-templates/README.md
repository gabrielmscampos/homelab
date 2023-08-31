# Virtual Machine templates

Execute `create_template.sh` script to create the following VM templates in Proxmox:

* debian-12: Dead simple Debian 12 VM
* debian-12-docker: Debian 12 with Docker
* debian-12-k8s: Debian 12 with pre-configured k8s
* debian-12-k8s-docker: Debian 12 with pre-configured k8s and Docker

All templates ship a default `admin` user and you can ssh into any VM using ssh keys configured in Proxmox (including Proxmox's own ssh key in case you need to ssh from Proxmox's console).

# Why so many templates?

Because of different use cases. If you want two mess with anything that do not need docker then clone the `debian-12` template, in case you need docker than `debian-12-docker`. The `debian-12-k8s-docker` is used to setup a kubernetes cluster with available docker sock in each node this is extremely useful if you setup Jenkins with dynamic agents that build docker containers in CI/CD pipelines, if you do not need that then setup your cluster using `debian-12-k8s`.

# Why Debian as base OS?

Debian is rock solid stable and community mantained.
