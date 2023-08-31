#!/bin/bash

SNIPPETS_DIR=/var/lib/vz/snippets
URL_VENDOR_SCRIPTS=https://raw.githubusercontent.com/gabrielmscampos/homelab/main/proxmox/vm-templates/vendors
URL_DEBIAN12_CI_IMAGE=https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2


function create_template() {

	VM_ID=$1
	VM_HOSTNAME=$2
	STORAGE=$3
	CI_IMAGE_PATH=$4
	CI_USERNAME=$5
	CI_CUSTOM=$6

	# Setting this using proxmox host`s authorized_keys
	# that way the host and anyone authorized to login in proxmox using ssh keys
	# can login to virtual machines created by these templates
	sshkeys="/root/.ssh/authorized_keys"

	# Create the VM
	qm create $VM_ID --name $VM_HOSTNAME

	# Link vmbr0 default network interface
	qm set $VM_ID --net0 virtio,bridge=vmbr0

	# Shenanigans to make the console work
	qm set $VM_ID --serial0 socket --vga serial0

	# Set default memory of 1G and 1 vCPU, these values can be changed on new VMs later 
	qm set $VM_ID --memory 1024 --cores 1

	# Set VM default storage drive and import cloudinit image
	qm set $VM_ID --scsi0 $STORAGE:0,import-from=$CI_IMAGE_PATH,discard=on

	# Change boot order to boot from scsi0 storage
	qm set $VM_ID --boot order=scsi0 --scsihw virtio-scsi-single

	# Enable qemu guest agent
	qm set $VM_ID --agent enabled=1,fstrim_cloned_disks=1

	# Set cloudinit drive
	qm set $VM_ID --ide2 $STORAGE:cloudinit

	# Set ipv4 using dhcp
	# Set ipv6 using auto = SLAAC (no bad effects on non-IPv6 networks)
	# Preferrably you want to set static IPs trough MAC addresses reservation lists
	# if your router doesn't have this feature, set an static ip in cloudinit configuration and
	# regenerate the image before launching de VM
	qm set $VM_ID --ipconfig0 "ip=dhcp,ip6=auto"

	# Set ssh keys
	qm set $VM_ID --sshkeys $sshkeys

	# Set cloudinit user
	qm set $VM_ID --ciuser $CI_USERNAME

	# Set cloudinit custom script
	# This script will be execute only within first boot
	qm set $VM_ID --cicustom $CI_CUSTOM

	# Resize template disk to 8G, these value can be changed in the VM
	qm disk resize $VM_ID scsi0 8G

	# Transform VM to template
	qm template $VM_ID
}

# Download debian 12 cloudinit base image
wget -P /tmp $URL_DEBIAN12_CI_IMAGE

# Download cloudinit custom scripts
mkdir -p $SNIPPETS_DIR
wget -N -P $SNIPPETS_DIR $URL_VENDOR_SCRIPTS/debian-vendor.yaml
wget -N -P $SNIPPETS_DIR $URL_VENDOR_SCRIPTS/debian-docker-vendor.yaml
wget -N -P $SNIPPETS_DIR $URL_VENDOR_SCRIPTS/debian-k8s-vendor.yaml
wget -N -P $SNIPPETS_DIR $URL_VENDOR_SCRIPTS/debian-k8s-docker-vendor.yaml

# Generate debian 12 base template
VM_ID=900
VM_HOSTNAME=debian-12
STORAGE=local-zfs
CI_IMAGE_PATH="/tmp/debian-12-generic-amd64.qcow2"
CI_USERNAME=admin
CI_CUSTOM="vendor=local:snippets/debian-vendor.yaml"

create_template $VM_ID $VM_HOSTNAME $STORAGE $CI_IMAGE_PATH $CI_USERNAME $CI_CUSTOM

# Generate debian 12 template from base template with docker pre-installed
VM_ID=901
VM_HOSTNAME=debian-12-docker
STORAGE=local-zfs
CI_IMAGE_PATH="/tmp/debian-12-generic-amd64.qcow2"
CI_USERNAME=admin
CI_CUSTOM="vendor=local:snippets/debian-docker-vendor.yaml"

create_template $VM_ID $VM_HOSTNAME $STORAGE $CI_IMAGE_PATH $CI_USERNAME $CI_CUSTOM

# Generate debian 12 template from base template with k8s pre-installed
VM_ID=902
VM_HOSTNAME=debian-12-k8s
STORAGE=local-zfs
CI_IMAGE_PATH="/tmp/debian-12-generic-amd64.qcow2"
CI_USERNAME=admin
CI_CUSTOM="vendor=local:snippets/debian-k8s-vendor.yaml"

create_template $VM_ID $VM_HOSTNAME $STORAGE $CI_IMAGE_PATH $CI_USERNAME $CI_CUSTOM

# Generate debian 12 template from base template with k8s + docker pre-installed
VM_ID=903
VM_HOSTNAME=debian-12-k8s-docker
STORAGE=local-zfs
CI_IMAGE_PATH="/tmp/debian-12-generic-amd64.qcow2"
CI_USERNAME=admin
CI_CUSTOM="vendor=local:snippets/debian-k8s-docker-vendor.yaml"

create_template $VM_ID $VM_HOSTNAME $STORAGE $CI_IMAGE_PATH $CI_USERNAME $CI_CUSTOM

# Remove artifacts
rm /tmp/debian-12-generic-amd64.qcow2
