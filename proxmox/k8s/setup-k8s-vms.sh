#!/bin/bash

setup_node() {

    VM_CLONE_ID=$1
    VM_ID=$2
    VM_HOSTNAME=$3
    VM_STORAGE=$4
    VM_DISK_INCREASE=$5
    VM_MEMORY=$6
    VM_CORES=$7
    VM_STARTUP=$8
    VM_MACADDR=$9

    # Clone from template
    qm clone $VM_CLONE_ID $VM_ID --full true --name $VM_HOSTNAME --storage $VM_STORAGE

    # Resize disk (clone base storage +)
    qm resize $VM_ID scsi0 $VM_DISK_INCREASE

    # Set number of cores, memory and stat on boot
    qm set $VM_ID --memory $VM_MEMORY --cores $VM_CORES --onboot 1

    # Set startup order
    qm set $VM_ID --startup $VM_STARTUP

    # Set mac address if given (useful for mac address reservation lists)
    if [ ! -z $VM_MACADDR ]
    then
        qm set $VM_ID --net0 virtio,bridge=vmbr0,macaddr=$VM_MACADDR
    fi

    # Start after creation
    qm start $VM_ID
}

# Setup staging controller
setup_node 903 700 k8s-controller-staging local-zfs +42G 4096 4 'order=2,up=30' A6:61:6B:7C:8A:E6

# Setup staging workers nodes
setup_node 903 701 k8s-node-01-staging local-zfs +42G 4096 2 'order=3'
setup_node 903 702 k8s-node-02-staging local-zfs +42G 4096 2 'order=3'

# Setup production controller
setup_node 903 800 k8s-controller-prod local-zfs +42G 8192 4 'order=3,up=30' 12:AC:C4:11:F0:3E

# Setup production workers nodes
setup_node 903 801 k8s-node-01-prod local-zfs +42G 8192 2 'order=4'
setup_node 903 802 k8s-node-02-prod local-zfs +42G 8192 2 'order=4'
setup_node 903 803 k8s-node-03-prod local-zfs +42G 8192 2 'order=4'
setup_node 903 804 k8s-node-04-prod local-zfs +42G 8192 2 'order=4'
setup_node 903 805 k8s-node-05-prod local-zfs +42G 8192 2 'order=4'
