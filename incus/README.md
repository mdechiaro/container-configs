## Get started

[Install](https://linuxcontainers.org/incus/docs/main/installing/#install-incus-from-a-package)

[Prep](https://linuxcontainers.org/incus/docs/main/installing/#machine-setup)

[Initialize](https://linuxcontainers.org/incus/docs/main/howto/initialize/#interactive-configuration)

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
