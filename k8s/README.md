# k8s

All files stored here are usable k8s components that I've been selfhosting or selfhosted in the past. Keep in mind that you may need to change environment variables for your preferences and update persistent volume (PV) configurations according to your environment (nodeAffinity paths and nfs server ip/paths)

# Componentes breakdown according to storage

* `local-`: Components with PV configured to use local storage in one node in the cluster
* `nfs-`: Components with PV configured to use nfs storage in external server
* `stateless-`: Componentes that do not need PV

# Why keep local components files?

They are used for learning, testing purposes and future reference. Also, there are some cases that is better to run applications using a local filesystem instead of a network filesystem (like some databases).
