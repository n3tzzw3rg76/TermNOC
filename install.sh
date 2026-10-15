#!/usr/bin/env bash
# ==============================================================================
# TermNOC Installer for Debian 13 (Trixie) & Debian 12 (Bookworm)
# ==============================================================================
set -e

if [ "$EUID" -ne 0 ]; then
  echo "[-] Please run this installer as root or with sudo."
  exit 1
fi

echo "[+] Updating package repositories..."
apt update

echo "[+] Installing prerequisite packages..."
apt install -y \
    python3 \
    python3-yaml \
    python3-rich \
    qemu-system-x86 \
    libvirt-daemon-system \
    libvirt-clients \
    virtinst \
    sshpass \
    iproute2 \
    iputils-ping \
    netcat-openbsd \
    libguestfs-tools \
    curl

echo "[+] Creating required system directories..."
mkdir -p /etc/termnoc
mkdir -p /srv/termnoc/images
mkdir -p /srv/termnoc/iso
mkdir -p /srv/termnoc/preseed

echo "[+] Installing scripts to /usr/local/bin/..."
if [ -f "bin/termnoc-display" ] && [ -f "bin/termnoc-menu" ]; then
    cp bin/termnoc-display /usr/local/bin/
    cp bin/termnoc-menu /usr/local/bin/
    chmod 755 /usr/local/bin/termnoc-display /usr/local/bin/termnoc-menu
    echo "    -> Installed: /usr/local/bin/termnoc-display"
    echo "    -> Installed: /usr/local/bin/termnoc-menu"
else
    echo "[-] Warning: bin/termnoc-display or bin/termnoc-menu not found in current directory!"
fi

echo "[+] Deploying automated preseed templates..."
if [ -f "preseed/deb13-standard.cfg" ]; then
    cp preseed/deb13-standard.cfg /srv/termnoc/preseed/
    chmod 644 /srv/termnoc/preseed/deb13-standard.cfg
    echo "    -> Deployed: /srv/termnoc/preseed/deb13-standard.cfg"
fi

echo "[+] Initializing configuration templates in /etc/termnoc/..."
shopt -s nullglob
example_configs=(config.example/*.yaml.example)
if [ ${#example_configs[@]} -gt 0 ]; then
    for f in "${example_configs[@]}"; do
        dest="/etc/termnoc/$(basename "$f" .example)"
        if [ ! -f "$dest" ]; then
            cp "$f" "$dest"
            chmod 640 "$dest"
            echo "    -> Created default: $dest"
        else
            echo "    -> Keeping existing: $dest"
        fi
    done
else
    echo "[-] Notice: No .yaml.example files found in config.example/"
fi
shopt -u nullglob

echo ""
echo "[✓] Installation complete!"
echo "    - Run 'termnoc-display' to launch the telemetry dashboard"
echo "    - Run 'sudo termnoc-menu' to launch the administration orchestrator"
