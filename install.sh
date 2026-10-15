#!/usr/bin/env bash
# ==============================================================================
# TermNOC Installer for Debian 13 (Trixie)
# ==============================================================================
set -e

if [ "$EUID" -ne 0 ]; then
  echo "[-] Please run this installer as root or with sudo."
  exit 1
fi

echo "[+] Installing prerequisite packages..."
apt update
apt install -y python3 python3-yaml python3-rich qemu-system-x86 libvirt-daemon-system \
               libvirt-clients virtinst sshpass iproute2 ping libguestfs-tools

echo "[+] Creating required directories..."
mkdir -p /etc/termnoc
mkdir -p /srv/termnoc/{images,iso,preseed}

echo "[+] Installing scripts to /usr/local/bin/..."
cp bin/termnoc-display /usr/local/bin/
cp bin/termnoc-menu /usr/local/bin/
chmod +x /usr/local/bin/termnoc-display /usr/local/bin/termnoc-menu

echo "[+] Deploying automated preseed templates..."
cp preseed/deb13-standard.cfg /srv/termnoc/preseed/

echo "[+] Initializing configuration templates in /etc/termnoc/..."
for f in config.example/*.yaml.example; do
  dest="/etc/termnoc/$(basename "$f" .example)"
  if [ ! -f "$dest" ]; then
    cp "$f" "$dest"
    echo "    -> Created: $dest"
  fi
done

echo "[+] Installation complete! Run 'termnoc-display' for telemetry or 'termnoc-menu' for management."
