## Get started

Run `scripts/init.sh` to initialize first time setup.

Run following commands to use incus without sudo.

```
sudo usermod -aG incus-admin $USER
newgrp incus-admin
```

Run `scripts/dns-container-names.sh` to enable DNS lookups on container names.

Run `scripts/update-default-firefox-icon.sh` to use container instead of OS package.

## Profile

Create profile and new container from it.

```
incus profile create work
cat fedora-work.yaml | incus profile edit work
```

## Launch

```
incus launch --profile work images:fedora/41/cloud work
incus exec work bash
```

It takes a few minutes for the provisioning to finish. The process can
be watched with tail.

```
tail -f /var/log/cloud-init-output.log
```

Once cloud-init finishes, then you can login as user
```
su <user>
```

# CPU

Add more cpus to container.
```
incus config set work limits.cpu 4
```

## Mounts

To share a folder between a host and container.
```
incus config device add firefox downloads disk source=/home/$USER/Downloads \
  path=/home/user/Downloads shift=true
```

# Backup

To backup a container.

NOTE: --optimized-storage only works if migrating to another LXD server
with a similar pool (e.g. zfs)


```
incus export work work.backup-$(date +%F).tar.gz --instance-only \
--optimized-storage
```

# Restore
To restore a backup. It requires the profile used by backup.

```
incus profile create work
cat fedora-work.yaml | incus profile edit work
incus import work.backup-$(date +%F).tar.gz
```
