# SMB

Filesystems over network play an important role in local network productivity with file sharing. Following this guide you can setup your own SMB LXC container in Proxmox.

# LXC container

From Proxmox console make sure you have downloaded the debian 12 LXC template and execute the following code:

```bash
pct create 100 /var/lib/vz/template/cache/debian-12-standard_12.0-1_amd64.tar.zst \
  --arch amd64 \
  --ostype debian \
  --hostname smb \
  --cores 1 \
  --memory 2048 \
  --swap 512 \
  --rootfs volume=local-zfs:8 \
  --net0 name=eth0,bridge=vmbr0,firewall=1,hwaddr=DA:A6:8F:8A:40:81,ip=dhcp,type=veth \
  --unprivileged 0 \
  --features nesting=1 \
  --onboot 1 \
  --ssh-public-keys ~/.ssh/authorized_keys
  
pct set 100 --mp0 /dpool/data,mp=/mnt/data
pct set 100 --mp1 /dpool/media,mp=/mnt/media
pct set 100 --mp2 /dpool/torrent,mp=/mnt/torrent
pct set 100 --mp3 /dpool/roms,mp=/mnt/roms
pct start 100
pct enter 100
```

This will create a debian 12 LXC container with ID 100 and enough resources for SMB. Note that the LXC mac address is explicitly set (useful for mac address reservation lists). Also some mount points are configured to store data per-share outside container's rootfs.

The last two lines of code will start the container and connect to its shell as root.

# Update and install SMB service

```bash
apt update
apt upgrade -y
apt install samba -y
```

# Setup groups for fine grained authentication

Instead of accessing all shares from one user, we can create multiple users with fine grained authentication. In order to simplify users permission we will use linux groups.

```bash
groupadd media-users
groupadd torrent-users
groupadd roms-users
groupadd data-users
```

# Setup users for specific services:

Create a specific user for media related services, it will only be able to access shares with `media-users` valid-users configuration:

```bash
useradd media-services -g users -G media-users
smbpasswd -a media-services
```

The same happens for torrent and roms related services:

```bash
useradd torrent-services -g users -G torrent-users
smbpasswd -a torrent-services
```

```bash
useradd roms-services -g users -G roms-users
smbpasswd -a roms-services
```

# Setup other users

These users can be created for each human with local network access or per-device. The following user has access to all available shares:

```bash
useradd myuser -g users -G data-users,media-users,torrent-users,roms-users
smbpasswd -a myuser
```

# SMB configuration

The `smb.conf` file is a boilerplate SMB configuration file with pre-configured simple options and four shares with fine grained authentication using the above linux groups, by using this configuration your SMB server will be acessible from your entire local network.

Restart the SMB service with:

```bash
systemctl restart smbd.service
```
