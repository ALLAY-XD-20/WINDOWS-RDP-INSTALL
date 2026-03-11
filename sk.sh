bash -c 'set -e
mkdir -p /opt
DB="/opt/lxc-rdp-db.txt"
touch $DB

cat >/usr/local/bin/lxc-rdp-create << "EOF"
#!/usr/bin/env bash
set -e
DB="/opt/lxc-rdp-db.txt"

read -p "Enter username: " USERNAME
read -p "CPU cores: " CPU
read -p "RAM (example 8g): " RAM
read -p "Disk (example 120G): " DISK

PASSWORD=$(openssl rand -base64 12 | tr -dc A-Za-z0-9 | head -c 10)

get_port(){
while true; do
PORT=$(shuf -i 20000-50000 -n1)
ss -tuln | grep -q ":$PORT " || { echo $PORT; return; }
done
}

RDP_PORT=$(get_port)
WEB_PORT=$(get_port)

while [ "$RDP_PORT" = "$WEB_PORT" ]; do
WEB_PORT=$(get_port)
done

CONTAINER="windows-$USERNAME-$(date +%s)"
DATA="$HOME/windows-$USERNAME"

mkdir -p "$DATA"

if [ ! -e /dev/kvm ]; then
echo "KVM not available"
exit 1
fi

docker run -d \
--name "$CONTAINER" \
--restart unless-stopped \
--device /dev/kvm \
--cap-add NET_ADMIN \
--security-opt seccomp=unconfined \
--memory "$RAM" \
--cpus "$CPU" \
-p $RDP_PORT:3389 \
-p $WEB_PORT:8006 \
-v "$DATA:/storage" \
-e VERSION=2025 \
-e DISK_SIZE="$DISK" \
-e USERNAME="$USERNAME" \
-e PASSWORD="$PASSWORD" \
-e AUTO_START=yes \
-e SKIP_CHECKS=yes \
-e ENABLE_KVM=yes \
dockurr/windows

IP=$(curl -s ifconfig.me || hostname -I | awk "{print \$1}")

echo "$USERNAME|$PASSWORD|$IP|$RDP_PORT|$WEB_PORT|$CONTAINER" >> $DB

echo ""
echo "==============================="
echo "RDP CREATED"
echo "==============================="
echo "Username : $USERNAME"
echo "Password : $PASSWORD"
echo "IP       : $IP"
echo "RDP Port : $RDP_PORT"
echo "Web      : http://$IP:$WEB_PORT"
echo "==============================="
EOF

chmod +x /usr/local/bin/lxc-rdp-create

cat >/usr/local/bin/lxc-rdp-list << "EOF"
#!/usr/bin/env bash
DB="/opt/lxc-rdp-db.txt"
printf "%-15s %-15s %-10s\n" "USERNAME" "IP" "RDP_PORT"
echo "---------------------------------------------"
while IFS="|" read -r USER PASS IP RDP WEB CONT; do
printf "%-15s %-15s %-10s\n" "$USER" "$IP" "$RDP"
done < $DB
EOF

chmod +x /usr/local/bin/lxc-rdp-list

cat >/usr/local/bin/lxc-rdp-info << "EOF"
#!/usr/bin/env bash
DB="/opt/lxc-rdp-db.txt"
USER=$1

if [ -z "$USER" ]; then
echo "Usage: lxc-rdp-info USERNAME"
exit 1
fi

grep "^$USER|" $DB | while IFS="|" read U P IP RDP WEB CONT; do
echo "================================"
echo "Username   : $U"
echo "Password   : $P"
echo "IP         : $IP"
echo "RDP Port   : $RDP"
echo "Web Panel  : http://$IP:$WEB"
echo "Container  : $CONT"
echo "================================"
done
EOF

chmod +x /usr/local/bin/lxc-rdp-info

echo "===================================="
echo "RDP SYSTEM INSTALLED"
echo ""
echo "Commands available:"
echo "lxc-rdp-create"
echo "lxc-rdp-list"
echo "lxc-rdp-info USERNAME"
echo "===================================="
'
