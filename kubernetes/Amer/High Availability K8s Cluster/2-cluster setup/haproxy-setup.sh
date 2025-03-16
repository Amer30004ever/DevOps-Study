#!/bin/bash

# Update system packages
apt update -y && apt upgrade -y

# Install HAProxy
apt install -y haproxy

# Configure HAProxy
cat <<EOF > /etc/haproxy/haproxy.cfg
global
    log /dev/log local0
    log /dev/log local1 notice
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
    stats timeout 30s
    user haproxy
    group haproxy
    daemon

defaults
    log global
    mode http
    option httplog
    option dontlognull
    timeout connect 5000
    timeout client 50000
    timeout server 50000

frontend kubernetes-api
    bind 192.168.2.166:6443
    mode tcp
    option tcplog
    default_backend kubernetes-master-nodes

backend kubernetes-master-nodes
    mode tcp
    option tcp-check
    balance roundrobin
    server masternode01 192.168.2.161:6443 check
    server masternode02 192.168.2.162:6443 check
    server masternode03 192.168.2.163:6443 check
EOF

# Restart HAProxy service
systemctl restart haproxy
systemctl enable haproxy

# Verify HAProxy status
systemctl status haproxy --no-pager

echo "HAProxy setup completed successfully!"
