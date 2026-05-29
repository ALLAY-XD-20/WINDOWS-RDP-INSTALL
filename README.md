# 🖥️ Windows 11 Automated RDP Setup Script


**By ALLAY XD 20**

---

[![License](https://img.shields.io/badge/License-MIT-blue)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Ubuntu-orange)](https://ubuntu.com/)
[![Tailscale](https://img.shields.io/badge/Tailscale-Optional-green)](https://tailscale.com/)

---

## 📌 Overview

This Bash script automates the setup of a **Windows 11 virtual machine** on Ubuntu 22/debine etc using **KVM/QEMU/WITHOUT KVM**, with the following features:

- Fully automated Windows 11 VM installation
- Allocates **most RAM, all CPU cores, and maximum disk space**
- Optional **Tailscale setup** for remote access
- Custom **RDP port forwarding**
- Headless VM support (**No VNC/SPICE**) for RDP-only access
- Interactive animated menu for ease of use

---

## ⚡ Features

| Option | Description |
|--------|-------------|
| 0️⃣  WINDOWS RDP SETUP | Full Windows 11 VM setup with RDP and optional Tailscale |
| 1️⃣  LOCALHOST RDP (Tailscale true) | Use an existing VM, auto-detect IP, forward RDP via Tailscale |
| 2️⃣  NO VNC TO ACCESS | Headless VM setup without VNC/SPICE; RDP-only |
| 3️⃣  EXIT | Exit the script |

---

## 🛠️ Prerequisites

- Ubuntu 22.04 or later
- Minimum 8GB RAM recommended
- KVM compatible CPU
- Internet connection for downloading Windows 11 ISO
- `curl`, `wget`, `iptables`, and `virt-manager` dependencies

---

## 🚀 Installation & Usage

```
bash <(curl -fsSL https://raw.githubusercontent.com/ALLAY-XD-20/RDP-SK/refs/heads/main/Run.sh)
