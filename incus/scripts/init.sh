#!/usr/bin/env bash
# first time setup of incus

if [[ $EUID -ne 0 ]]; then
  echo "script needs to be run as root."
  exit 1
fi

if ! command -v incus > /dev/null; then
  echo "install incus first."
  exit 1
fi

if ! grep incus /etc/group; then
  if grep incus /usr/lib/group; then
    grep incus /usr/lib/group >> /etc/group
  else
    echo "incus groups missing in /etc/group."
    exit 1
  fi
fi

# enable unprivileged containers
usermod -v 1000000-1000999999 -w 1000000-1000999999 root

systemctl enable incus
systemctl start incus

incus admin init --preseed ../admin-preseed.yaml

# allow traffic through firewall
if command -v firewall-cmd > /dev/null; then
  firewall-cmd --zone=trusted --change-interface=incusbr0 --permanent
  firewall-cmd --reload
fi
