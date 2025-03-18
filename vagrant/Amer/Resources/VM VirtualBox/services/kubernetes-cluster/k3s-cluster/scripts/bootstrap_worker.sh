#!/bin/bash
set -ex

# Wait until the master has written the token to the shared folder
until [ -f /vagrant/k3s-token ]; do
  echo "Waiting for master token..."
  sleep 5
done

# Read the token from the shared folder
TOKEN=$(cat /vagrant/k3s-token)

# Wait for the master API to be accessible (port 6443)
while ! nc -z ${K3S_MASTER_IP} 6443; do
  echo "Waiting for master API to be available..."
  sleep 2
done

# Install K3s agent if not already installed
if ! command -v k3s >/dev/null; then
  curl -sfL https://get.k3s.io | \
    K3S_URL="https://${K3S_MASTER_IP}:6443" \
    K3S_TOKEN="${TOKEN}" \
    sh -
  echo "Worker node joined the K3s cluster successfully!"
else
  echo "K3s agent is already installed. Skipping installation."
fi
