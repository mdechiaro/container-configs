#!/usr/bin/env bash
# updates default firefox gnome desktop icon to use container instead

if [[ $EUID == 0 ]]; then
  echo "script does not need root privileges."
  exit 1
fi

if [[ $# != 1 ]]; then
  echo "Usage: ${0} name"
  exit 1
fi

if ! [ -d ${HOME}/.local/share/applications ]; then
  mkdir -p ${HOME}/.local/share/applications
fi

cp /usr/share/applications/org.mozilla.firefox.desktop \
  ${HOME}/.local/share/applications

sed -i \
  -e "s/^Exec=firefox %u/Exec=incus exec ${1} -- su -l user -c \"firefox %u\"/g" \
  -e "s/^Exec=firefox --new-window %u/Exec=incus exec ${1} -- su -l user -c \"firefox --new-window %u\"/g" \
  -e "s/^Exec=firefox --private-window %u/Exec=incus exec ${1} -- su -l user -c \"firefox --private-window %u\"/g" \
  -e "s/^Exec=firefox --ProfileManager/Exec=incus exec ${1} -- su -l user -c \"firefox --ProfileManager\"/g" \
  ${HOME}/.local/share/applications/org.mozilla.firefox.desktop

update-desktop-database -q
