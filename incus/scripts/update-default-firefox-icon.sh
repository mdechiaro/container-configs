#!/usr/bin/env bash
# updates default firefox gnome desktop icon to use container instead

if [[ $EUID -ne 0 ]]; then
  echo "script needs to be run as root."
  exit 1
fi

if [[ $# != 1 ]]; then
  echo "Usage: ${0} <container_name>"
  exit 1
fi

mkdir -p /usr/local/share/applications/
cp /usr/share/applications/org.mozilla.firefox.desktop \
  /usr/local/share/applications/
sed -i "s/^Exec=firefox/Exec=incus exec ${1} -- su -l user -c firefox/g" \
  /usr/local/share/applications/org.mozilla.firefox.desktop

update-desktop-database
