#!/usr/bin/env bash
# enable dns lookups on container names
# fqdn is container_name.$DNS_DOMAIN

DNS_DOMAIN="incus"

if [[ $EUID -ne 0 ]]; then
  echo "script needs to be run as root."
  exit 1
fi

if ! systemctl is-enabled incus.service > /dev/null; then
  echo "incus not enabled."
  exit 1
fi

# enable on managed bridge interfaces
INTERFACE=$(incus network list | grep YES | grep bridge | awk -F '| ' '{print $2}' | tr '\n' ' ')

if [[ ! -d /etc/systemd/system/incus.service.d/ ]]; then
  mkdir /etc/systemd/system/incus.service.d/
fi

for i in $INTERFACE; do
  echo "Setting up systemd service for ${i}."

  DNS_ADDRESS=$(incus network get ${i} ipv4.address | cut -d / -f 1)

  cat <<EOF> /etc/systemd/system/incus.service.d/dns-${i}.conf
[Unit]
Description=Incus per-link DNS configuration for ${i}

[Service]
ExecStartPost=resolvectl dns ${i} ${DNS_ADDRESS}
ExecStartPost=resolvectl domain ${i} ~${DNS_DOMAIN}
ExecStartPost=resolvectl dnssec ${i} off
ExecStartPost=resolvectl dnsovertls ${i} off
ExecStopPost=resolvectl revert ${i}
RemainAfterExit=yes
EOF

done

systemctl daemon-reload
systemctl restart incus
