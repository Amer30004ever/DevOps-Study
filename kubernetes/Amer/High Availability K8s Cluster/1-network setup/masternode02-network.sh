#!/bin/bash

# Fix potential package issues
sudo sed -i '/^deb file:\/cdrom/ s/^/#/' /etc/apt/sources.list
sudo dpkg --configure -a

# Update and upgrade system
sudo apt update
#sudo apt upgrade -y
sudo apt install network-manager -y

# Configure NetworkManager
sudo bash -c 'cat > /etc/NetworkManager/NetworkManager.conf <<EOF
[ifupdown]
managed=true
EOF'

sudo systemctl restart NetworkManager

# Configure Netplan
sudo bash -c 'cat > /etc/netplan/00-installer-config.yaml <<EOF
network:
  version: 2
  renderer: NetworkManager
  ethernets:
    ens33:
      dhcp4: no
      addresses: [192.168.2.162/24]
      gateway4: 192.168.2.2
      nameservers:
        addresses:
          - 8.8.8.8
EOF'

sudo netplan apply
sudo systemctl restart NetworkManager

# Add DNS servers
sudo bash -c 'cat > /etc/resolv.conf <<EOF
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF'

# Verify System Clock
sudo timedatectl set-ntp on

# Update /etc/hosts
sudo bash -c 'cat >> /etc/hosts <<EOF
192.168.2.161 masternode01
192.168.2.162 masternode02
192.168.2.163 masternode03
192.168.2.164 workernode01
192.168.2.165 workernode02
EOF'

# Set Hostname
sudo hostnamectl set-hostname masternode02

# Verify IP configuration
ip a
