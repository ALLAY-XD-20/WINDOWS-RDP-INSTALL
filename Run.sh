#!/usr/bin/env bash
set -e

# =========================================
# WINDOWS SERVER 2025 DOCKER INSTALLER
# MODE: KVM / NO-KVM SELECTOR
# AUTHOR: Pawan
# =========================================

WIN_USER="docker"
WIN_PASS="Docker@2025!"
CONTAINER_NAME="windows-server-2025"
DATA_DIR="$HOME/windows-data"

# =========================================
# MENU
# =========================================
echo "======================================"
echo "   Windows Server 2025 Installer"
echo "======================================"
echo "1) Install WITH KVM (Fast Performance)"
echo "2) Install WITHOUT KVM (Compatibility Mode)"
echo "======================================"
read -p "Select option (1/2): " MODE

# =========================================
# USER INPUT
# =========================================
read -p "Enter CPU cores (e.g. 8): " CPU_CORES
read -p "Enter RAM size (e.g. 24g): " RAM_SIZE
read -p "Enter Disk size (e.g. 120G): " DISK_SIZE

mkdir -p "$DATA_DIR"
export DOCKER_BUILDKIT=1

# Remove old container
docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

# =========================================
# MODE HANDLER
# =========================================
if [ "$MODE" == "1" ]; then

  echo ""
  echo "[INFO] Installing WITH KVM..."

  # HARD CHECK
  if [ ! -e /dev/kvm ]; then
    echo "[ERROR] /dev/kvm not found. KVM is not supported on this system."
    exit 1
  fi

  docker run -d \
    --name "$CONTAINER_NAME" \
    --restart unless-stopped \
    --device /dev/kvm \
    --cap-add NET_ADMIN \
    --security-opt seccomp=unconfined \
    --memory "$RAM_SIZE" \
    --cpus "$CPU_CORES" \
    -p 3389:3389 \
    -p 8006:8006 \
    -v "$DATA_DIR:/storage" \
    -e VERSION=2025 \
    -e DISK_SIZE="$DISK_SIZE" \
    -e USERNAME="$WIN_USER" \
    -e PASSWORD="$WIN_PASS" \
    -e AUTO_START=yes \
    -e SKIP_CHECKS=yes \
    -e ENABLE_KVM=yes \
    dockurr/windows

elif [ "$MODE" == "2" ]; then

  echo ""
  echo "[INFO] Installing WITHOUT KVM..."

  docker run -d \
    --name "$CONTAINER_NAME" \
    --restart unless-stopped \
    --cap-add NET_ADMIN \
    --security-opt seccomp=unconfined \
    --memory "$RAM_SIZE" \
    --cpus "$CPU_CORES" \
    -p 3389:3389 \
    -p 8006:8006 \
    -v "$DATA_DIR:/storage" \
    -e VERSION=2025 \
    -e DISK_SIZE="$DISK_SIZE" \
    -e USERNAME="$WIN_USER" \
    -e PASSWORD="$WIN_PASS" \
    -e AUTO_START=yes \
    -e SKIP_CHECKS=yes \
    -e ENABLE_KVM=no \
    dockurr/windows

else
  echo "[ERROR] Invalid option selected!"
  exit 1
fi

# =========================================
# FINAL OUTPUT
# =========================================
echo ""
echo "======================================"
echo " Windows Server 2025 Started"
echo "======================================"
echo "RDP: YOUR_SERVER_IP:3389"
echo "Web UI: YOUR_SERVER_IP:8006"
echo "Username: $WIN_USER"
echo "Password: $WIN_PASS"
echo ""
echo "Logs:"
echo "docker logs -f $CONTAINER_NAME"
