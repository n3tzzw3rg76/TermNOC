# ⚡ TermNOC // Terminal Operations Center & KVM Orchestrator

```text
 _____                    _   _  ____   _____ 
|_   _|                  | \ | |/ __ \ / ____|
  | |  ___ _ __ _ __ ___ |  \| | |  | | |     
  | | / _ \ '__| '_ ` _ \| . ` | |  | | |     
  | ||  __/ |  | | | | | | |\  | |__| | |____ 
  \_/ \___|_|  |_| |_| |_|_| \_|\____/ \_____|
```

> **High-Density Terminal Operations Center, Telemetry Dashboard & KVM Orchestrator for Debian 13 (Trixie).**

---

## 🧭 Philosophy: Why Pure SSH & TTY1?

Managing a distributed fleet of bare-metal hypervisors, Raspberry Pi appliances, and customer VPS instances across both professional and private environments inevitably leads to a familiar dilemma: finding an infrastructure overview that doesn't become a maintenance project of its own.

Most modern monitoring stacks are heavy. They demand bloated web servers, complex databases, continuous background scraping, and web interfaces that feel sluggish when accessing them on the move. Every system I run is hardened differently, but they all share a single, reliable constant: **SSH**.

TermNOC was built around four foundational rules:
1. **Child of the 70s**: Grown up on the terminal. A high-contrast, distraction-free command-line interface provides the clearest overview possible.
2. **Hardened Security**: Password authentication is disabled across all nodes. Relying exclusively on SSH key/certificate authentication provides a security baseline that exposed web dashboards cannot match.
3. **Flawless Mobile Connectivity**: When troubleshooting via mobile terminal clients over poor cellular coverage, an SSH session remains fast and resilient while web apps stall.
4. **Zero Overhead**: Preserves CPU cycles and RAM on the host for actual virtualization workloads instead of monitoring stacks.

---

## ⚡ Architecture & Features

TermNOC is built with Python and the **Rich** TUI framework, offering rigid, double-bordered table layouts designed not to drift or flicker across standard terminal dimensions.

### 1. termnoc-display (Live Telemetry HUD)
Designed for continuous, informal situational awareness on a physically attached screen (**`tty1` Kiosk**) or within a persistent `tmux` pane:
* **Asynchronous Engine**: 5-second polling cycle that does not block screen rendering during network latency spikes.
* **Hypervisor Metrics**: Real-time CPU load, memory utilization, swap, and system uptime.
* **KVM Virtual Machines**: Direct `libvirt`/`virsh` integration showing VM state, allocated vCPUs, RAM, and boot autostart flags.
* **LAN Hardware**: TCP port scans and pure ICMP ping latency checks for Raspberry Pis, DNS appliances, and ESP32 hardware (e.g. NerdMiners).
* **Remote & Customer Fleets**: Connectivity monitoring across remote VPS and customer environments.

### 2. termnoc-menu (Administrative Orchestrator)
A guided control suite for daily operations:
* **VM Lifecycle Management**: Start, gracefully shut down, reset, and toggle autostart for KVM instances.
* **Interactive Fleet SSH**: Jump directly into any configured server using defined identities.
* **Batch Maintenance**: Run non-interactive security and package updates across target server groups.
* **Zero-Touch Debian 13 Provisioning**: Spawns clean guest VMs via Preseed unattended automation (CH locale, DE-CH keyboard, headless OpenSSH, QEMU Guest Agent) in under 2 minutes.

---

## 🛠️ Configuration Structure

TermNOC is 100% YAML-driven. Infrastructure changes never require modifying python scripts.

All configuration files reside in `/etc/termnoc/`:

| File | Purpose |
| :--- | :--- |
| `types.yaml` | Port definitions and server profiles (e.g. `webserver`, `dns`, `virtualmin`, `ping_only`). |
| `local.yaml` | Hypervisor-specific parameters and local storage paths. |
| `lan.yaml` | Internal network appliances and microcontrollers. |
| `remote.yaml` | Dedicated servers and remote cloud VPS nodes. |
| `customer.yaml` | Managed customer instances. |

---

## 🚀 Quickstart

### Prerequisites
* **Debian 13 (Trixie)** or **Debian 12 (Bookworm)**
* Bridged networking configured (`br0`)
* Root or sudo privileges

### Installation

Clone the repository and run the automated installer:

```bash
git clone https://github.com/n3tzzw3rg76/TermNOC.git
cd TermNOC
sudo ./install.sh
```

### Setup Configuration Files

Copy and adjust the example configuration files:

```bash
sudo cp config.example/types.yaml.example /etc/termnoc/types.yaml
sudo cp config.example/lan.yaml.example /etc/termnoc/lan.yaml
sudo cp config.example/remote.yaml.example /etc/termnoc/remote.yaml
sudo cp config.example/customer.yaml.example /etc/termnoc/customer.yaml
```

### Usage

* Launch the Live Dashboard:
  ```bash
  termnoc-display
  ```
* Launch the Admin Menu:
  ```bash
  sudo termnoc-menu
  ```

---

## 📺 Optional: Running on TTY1 (Kiosk Mode)

To have `termnoc-display` launch automatically on boot on the physically connected monitor (`tty1`):

1. Configure systemd autologin for your user on `tty1`:
   ```bash
   sudo systemctl edit getty@tty1
   ```
2. Add:
   ```ini
   [Service]
   ExecStart=
   ExecStart=-/sbin/agetty --autologin <YOUR_USER> --noclear %I $TERM
   ```
3. Append to `~/.bash_profile` (or `~/.profile`):
   ```bash
   if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
       exec termnoc-display
   fi
   ```

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

Developed by [Dominique Blake-Hofer](https://blake-hofer.net).
