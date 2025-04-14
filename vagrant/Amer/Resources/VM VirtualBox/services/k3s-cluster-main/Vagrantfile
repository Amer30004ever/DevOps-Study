Vagrant.configure("2") do |config|
  # Use Ubuntu 22.04 (jammy64) as the base box
  config.vm.box = "ubuntu/jammy64"
  config.vm.box_version = "20241002.0.0"

  # Increase the boot timeout to give the VM more time to start (e.g., 600 seconds)
  config.vm.boot_timeout = 600
  
  # Disable automatic insertion of SSH keys to avoid conflicts with your local SSH agent
  config.ssh.insert_key = false

  # Use Vagrant's default synced folder to share files with /vagrant in all VMs
  config.vm.synced_folder ".", "/vagrant", type: "virtualbox"

  # Common provisioning: update DNS settings and /etc/hosts
  config.vm.provision "shell", inline: <<-SHELL
    echo "[Resolve]
    DNS=8.8.8.8 1.1.1.1
    FallbackDNS=8.8.4.4 1.0.0.1" | sudo tee /etc/systemd/resolved.conf
    sudo systemctl restart systemd-resolved

    grep -qF '192.168.56.101' /etc/hosts || echo '192.168.56.101 controlplane1' | sudo tee -a /etc/hosts
    grep -qF '192.168.56.102' /etc/hosts || echo '192.168.56.102 node011' | sudo tee -a /etc/hosts
    grep -qF '192.168.56.103' /etc/hosts || echo '192.168.56.103 node022' | sudo tee -a /etc/hosts
  SHELL

  # Master node configuration
  config.vm.define "controlplane1" do |master|
    master.vm.hostname = "controlplane1"
    master.vm.network "private_network", ip: "192.168.56.101"
    master.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.cpus = 2
    end

    # Provision master with bootstrap script
    master.vm.provision "shell", path: "scripts/bootstrap_master.sh"
  end

  # Worker nodes configuration (node011 and node022)
  ["node011", "node022"].each do |name|
    config.vm.define name do |node|
      node.vm.hostname = name
      ip = (name == "node011") ? "192.168.56.102" : "192.168.56.103"
      node.vm.network "private_network", ip: ip
      node.vm.provider "virtualbox" do |vb|
        vb.memory = 1024
        vb.cpus = 2
      end

      # Pass the master IP to worker nodes via an environment variable and run bootstrap script
      node.vm.provision "shell", path: "scripts/bootstrap_worker.sh", env: { "K3S_MASTER_IP" => "192.168.56.101" }
    end
  end
end
