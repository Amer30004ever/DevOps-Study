#!/bin/bash
set -ex

# Install K3s master if not already installed
if ! command -v k3s >/dev/null; then
  # Install K3s master with --disable=traefik and set kubeconfig mode
  curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable=traefik --write-kubeconfig-mode=644" sh -

  # Wait until the token is generated
  until [ -f /var/lib/rancher/k3s/server/node-token ]; do
    sleep 2
  done

  # Change ownership of the kubeconfig so the vagrant user can access it
  sudo chown vagrant:vagrant /etc/rancher/k3s/k3s.yaml
  
  # Create .kube directory and copy kubeconfig for vagrant user
  mkdir -p /home/vagrant/.kube
  cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
  chown -R vagrant:vagrant /home/vagrant/.kube

  # Copy the generated token to the shared folder for worker nodes
  sudo cp /var/lib/rancher/k3s/server/node-token /vagrant/k3s-token
  sudo chmod 644 /vagrant/k3s-token

  echo "K3s master installed, kubeconfig ownership updated, .kube directory set, and token shared successfully!"
else
  echo "K3s master is already installed. Skipping installation."
fi
