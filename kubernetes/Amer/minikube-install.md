      # Function to log messages
      log() {
          echo -e "\n[INFO] $1\n"
      }

      # Install Docker
      log "Installing Docker..."
      sudo apt-get update
      sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
      sudo apt-get update
      sudo apt-get install -y docker-ce docker-ce-cli containerd.io

      # Add the vagrant user to the docker group
      sudo usermod -aG docker vagrant

      # Verify Docker installation
      log "Verifying Docker installation..."
      if ! docker --version; then
          echo "[ERROR] Docker installation failed. Exiting."
          exit 1
      fi

      # Define the stable version of kubectl to install
      STABLE_KUBECTL_VERSION="v1.28.2"

      # Add Kubernetes repository and key
      log "Adding Kubernetes repository and key..."
      sudo mkdir -p /etc/apt/keyrings
      curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
      sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
      echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
      sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list

      # Update package index and install kubectl
      log "Installing kubectl..."
      sudo apt-get update
      sudo apt-get install -y kubectl

      # Verify kubectl installation
      log "Verifying kubectl installation..."
      if ! kubectl version --client; then
          echo "[ERROR] kubectl installation failed. Exiting."
          exit 1
      fi

      # Install Minikube
      log "Installing Minikube..."
      curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
      sudo install minikube-linux-amd64 /usr/local/bin/minikube
      rm minikube-linux-amd64

      # Verify Minikube installation
      log "Verifying Minikube installation..."
      if ! minikube version; then
          echo "[ERROR] Minikube installation failed. Exiting."
          exit 1
      fi

      # Start Minikube with Docker driver as the vagrant user
      log "Starting Minikube with Docker driver..."
      sudo -u vagrant minikube start --driver=docker || {
          echo "[ERROR] Failed to start Minikube. Exiting."
          exit 1
      }
