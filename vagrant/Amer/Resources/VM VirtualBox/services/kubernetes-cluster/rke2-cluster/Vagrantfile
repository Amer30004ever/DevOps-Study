Vagrant.require_version ">= 2.2.17"
Vagrant.configure("2") do |config|
  config.vm.box = "generic/ubuntu2004"
  config.vm.box_version = "4.3.12"

  # Shared variables
  server_ip = "192.168.56.101"
  token = "vagrant-rke2"

  # ------------------------------------
  # (DNS settings & /etc/hosts update)
  # ------------------------------------
  config.vm.provision "shell", inline: <<-SHELL
    # Configure systemd-resolved for proper DNS resolution
    echo "[Resolve]
    DNS=8.8.8.8 1.1.1.1
    FallbackDNS=8.8.4.4 1.0.0.1" | sudo tee /etc/systemd/resolved.conf
    sudo systemctl restart systemd-resolved

    # Update /etc/hosts with control plane and worker IPs if not already present
    grep -qF '#{server_ip}' /etc/hosts || echo '#{server_ip} rke2-controlplane' | sudo tee -a /etc/hosts
    grep -qF '192.168.56.102' /etc/hosts || echo '192.168.56.102 rke2-worker1' | sudo tee -a /etc/hosts

    # Disable UFW  firewall (testing)
    if command -v ufw; then
      sudo ufw disable
    fi
  SHELL

  # -------------------------
  # Control Plane Node Setup
  # -------------------------
  config.vm.define "rke2-controlplane" do |node|
    node.vm.hostname = "rke2-controlplane"
    node.vm.network "private_network", ip: server_ip, netmask: "255.255.255.0"
    node.vm.provision "Set DNS", type: "shell", inline: "systemd-resolve --set-dns=8.8.8.8 --interface=eth0"

    # RKE2 installation for control plane
    node.vm.provision :rke2, run: "once" do |rke2|
      rke2.installer_url = "https://get.rke2.io"
      rke2.env = [
        "INSTALL_RKE2_CHANNEL=stable",
        "INSTALL_RKE2_TYPE=server"
      ]
      rke2.env_path = "/etc/rancher/rke2/install.env"
      rke2.env_mode = "0600"
      rke2.env_owner = "root:root"
      rke2.config_mode = "0644"
      rke2.config_owner = "root:root"
      rke2.config = <<~YAML
        write-kubeconfig-mode: "0644"
        node-external-ip: #{server_ip}
        node-ip: #{server_ip}
        token: #{token}
        cni: calico
      YAML
      rke2.skip_start = false
    end


    # Copy kubeconfig to the vagrant home for easier access from the host
    node.vm.provision "shell", inline: <<-SHELL
      sleep 10
      if [ -f /etc/rancher/rke2/rke2.yaml ]; then
        cp /etc/rancher/rke2/rke2.yaml /home/vagrant/rke2.yaml
        sudo chown vagrant:vagrant /home/vagrant/rke2.yaml
        echo "Kubeconfig copied to /home/vagrant/rke2.yaml"
      else
        echo "Kubeconfig not found!"
      fi
    SHELL

    node.vm.provider "virtualbox" do |vb|
      vb.memory = 4096
      vb.cpus = 2
    end
  end

  # -------------------------
  # Worker Node Setup
  # -------------------------
  config.vm.define "rke2-worker1" do |node|
    node.vm.hostname = "rke2-worker1"
    node.vm.network "private_network", ip: "192.168.56.102", netmask: "255.255.255.0"
    node.vm.provision "Set DNS", type: "shell", inline: "systemd-resolve --set-dns=8.8.8.8 --interface=eth0"

    # RKE2 installation for worker node (agent)
    node.vm.provision :rke2, run: "once" do |rke2|
      rke2.installer_url = "https://get.rke2.io"
      rke2.env = [
        "INSTALL_RKE2_CHANNEL=stable",
        "INSTALL_RKE2_TYPE=agent"
      ]
      rke2.env_path = "/etc/rancher/rke2/install.env"
      rke2.env_mode = "0600"
      rke2.env_owner = "root:root"
      rke2.config_mode = "0644"
      rke2.config_owner = "root:root"
      rke2.config = <<~YAML
        token: #{token}
        server: https://#{server_ip}:9345
      YAML
      rke2.skip_start = false
    end

    node.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.cpus = 2
    end
  end
end
