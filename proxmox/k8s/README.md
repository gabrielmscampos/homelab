# Creating the k8s cluster

Considering you already created the VM template from `vm-templates` section, you can proceed execute the `setup-k8s-vms.sh` script to create your cluster nodes. By default the script create both the staging and production cluster with pre-configured VM hardware/config, so you may need to change that to fit your resources.

# Configuring the controller

Running the following command will configure you control-plane with a pod network living at `10.244.0.0/16`.

```bash
sudo kubeadm init --control-plane-endpoint=$(hostname -I | awk '{ print $1 }') --node-name $(hostname) --pod-network-cidr=10.244.0.0/16
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
```

Using the `.kube/config` file you can config `kubectl` in your personal desktop/laptop.

# Joining the workers nodes to the cluster

First print the join command in the controller node with the following command:

```bash
kubeadm token create --print-join-command
```

Following the command output, execute it with `sudo` in each worker node. You can check if nodes joined successfully with:

```bash
kubectl get nodes
```

```bash
NAME                     STATUS   ROLES           AGE   VERSION
k8s-controller-staging   Ready    control-plane   46h   v1.28.1
k8s-node-01-staging      Ready    <none>          46h   v1.28.1
k8s-node-02-staging      Ready    <none>          46h   v1.28.1
k8s-node-03-staging      Ready    <none>          46h   v1.28.1
```
