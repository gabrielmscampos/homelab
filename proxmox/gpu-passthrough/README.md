# GPU Passthrough in PVE (Intel)

GPU Passthrough is decisive if you want to accelerate computing power inside your VM.

## Harware requirements

* Motherboard has support for VT-d
* CPU has support for VT-d

## Intel VT-d

For this to work you will need to enable VT-d in you bios, for my current motherboard I can enable it following:

```
Chipset -> North Bridge -> Intel (R) VT for Directed I/O Configuration -> Intel(R) VT-d (enable)
```

## IOMMU

After enabling VT-d in bios you need to instruct you OS to allow devices passthrough.

### UEFI

If you are using UEFI you need to edit `/etc/kernel/cmdline` and append `intel_iommu=on` like:

```
root=ZFS=rpool/ROOT/pve-1 boot=zfs intel_iommu=on
```

### Legacy

Otherwise, if you are using legacy bios boot you can edit `/etc/default/grub` and append `intel_iommu=on` at the end of `GRUB_CMDLINE_LINUX_DEFAULT` directive:

```
# If you change this file, run 'update-grub' afterwards to update
# /boot/grub/grub.cfg.
# For full documentation of the options in this file, see:
#   info -f grub -n 'Simple configuration'

GRUB_DEFAULT=0
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on"
.
.
.
```
