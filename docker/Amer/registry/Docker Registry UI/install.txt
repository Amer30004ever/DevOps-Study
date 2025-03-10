#Full Guide to Setting Up a Docker Registry
#Prerequisites
#A Linux-based system (e.g., Ubuntu).

#Docker installed on the system.

#Root or sudo access.

#Step 1: Install Docker
#If Docker is not already installed, follow these steps:


# Update the package index
sudo apt-get update

# Install Docker
sudo apt-get install -y docker.io

# Start and enable Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Verify Docker installation
docker --version

#Step 2: Prepare Configuration Files
#You provided four files:

#credentials.yml - Registry configuration with authentication.
#htpasswd - Contains the hashed password for the registry user.
#simple.yml - A simpler registry configuration without authentication.
#populate.sh

#We will use credentials.yml and htpasswd for this guide.

#File Locations
#credentials.yml → /etc/docker/registry/config.yml
#htpasswd → /etc/docker/registry/htpasswd

##Step 3: Create Storage Directory
The registry stores Docker images in a directory. Create the directory:

sudo rm -rf /var/lib/registry/*
sudo mkdir -p /var/lib/registry

# Create the registry configuration directory
sudo rm -rf /etc/docker/registry/*
sudo mkdir -p /etc/docker/registry

# Create a directory for certificates
sudo mkdir -p /etc/docker/registry/certs

#Step 4: Create the Configuration Files
#1. credentials.yml
#Create the file /etc/docker/registry/config.yml with the following content:

sudo vi /etc/docker/registry/config.yml

version: 0.1
log:
  fields:
    service: registry
storage:
  delete:
    enabled: true
  cache:
    blobdescriptor: inmemory
  filesystem:
    rootdirectory: /var/lib/registry
http:
  addr: :5000
  headers:
    X-Content-Type-Options: [nosniff]
    Access-Control-Allow-Origin: ['http://localhost']
    Access-Control-Allow-Methods: ['HEAD', 'GET', 'OPTIONS', 'DELETE']
    Access-Control-Allow-Headers: ['Authorization', 'Accept']
    Access-Control-Max-Age: [1728000]
    Access-Control-Allow-Credentials: [true]
    Access-Control-Expose-Headers: ['Docker-Content-Digest']
  tls:
    certificate: /etc/docker/registry/certs/domain.crt
    key: /etc/docker/registry/certs/domain.key
auth:
  htpasswd:
    realm: basic-realm
    path: /etc/docker/registry/htpasswd
	
#2. htpasswd
Create the file /etc/docker/registry/htpasswd with the following steps:

#Install htpasswdy
sudo apt-get install apache2-utils -y

#Create a New htpasswd File
htpasswd -cB /etc/docker/registry/htpasswd registry
New password:
Re-type new password:
Adding password for user registry

#Verify the htpasswd File
cat /etc/docker/registry/htpasswd

#should be like this:
registry:$2y$11$1bmuJLK8HrQl5ACS/WeqRuJLUArUZfUcP2R23asmozEpfN76.pCHy

#3. Create simple.yml File
sudo vi /etc/docker/registry/simple.yml

version: '2.0'
services:
  registry:
    image: registry:2.7
    ports:
      - 5000:5000
    volumes:
      - ./registry-data:/var/lib/registry
      - ./registry-config/simple.yml:/etc/docker/registry/config.yml

  ui:
    image: joxit/docker-registry-ui:latest
    ports:
      - 80:80
    environment:
      - REGISTRY_TITLE=My Private Docker Registry
      - REGISTRY_URL=http://192.168.2.139:5000
      - SINGLE_REGISTRY=true
    depends_on:
      - registry

#4. Create populate.sh File
#!/bin/bash

docker tag joxit/docker-registry-ui:static localhost:5000/joxit/docker-registry-ui:static
docker tag joxit/docker-registry-ui:static localhost:5000/joxit/docker-registry-ui:0.3
docker tag joxit/docker-registry-ui:static localhost:5000/joxit/docker-registry-ui:0.3.0
docker tag joxit/docker-registry-ui:static localhost:5000/joxit/docker-registry-ui:0.3.0-static
docker tag joxit/docker-registry-ui:static localhost:5000/joxit/docker-registry-ui:0.3-static

docker push localhost:5000/joxit/docker-registry-ui

docker tag registry:2.6.2 localhost:5000/registry:latest
docker tag registry:2.6.2 localhost:5000/registry:2.6.2
docker tag registry:2.6.2 localhost:5000/registry:2.6
docker tag registry:2.6.2 localhost:5000/registry:2.6.0
docker tag registry:2.6.2 localhost:5000/registry:2

docker push localhost:5000/registry

docker-compose -f simple.yml up -d

#Run Populate Script
./populate.sh

##Step 5: Start the Docker Registry
#Run the Docker Registry container using the configuration files:

sudo docker run -d \
  -p 5000:5000 \
  --restart=always \
  --name registry \
  -v /var/lib/registry:/var/lib/registry \
  -v /etc/docker/registry:/etc/docker/registry \
  registry:2
  
##Step 6: Verify the Registry
Check if the registry is running:


curl http://localhost:5000/v2/

You should see an empty JSON object {} as the response, indicating the registry is running.

##Step 7: Secure the Registry with TLS (Optional but Recommended)
To secure the registry with HTTPS, generate self-signed certificates or use certificates from a trusted CA.

#Generate Self-Signed Certificates

# Generate certificates
sudo openssl req -newkey rsa:4096 -nodes -sha256 \
  -keyout /etc/docker/registry/certs/domain.key \
  -x509 -days 365 -out /etc/docker/registry/certs/domain.crt

#Update config.yml for TLS
#Edit /etc/docker/registry/config.yml to include the TLS configuration:

http:
  addr: :5000
  tls:
    certificate: /etc/docker/registry/certs/domain.crt
    key: /etc/docker/registry/certs/domain.key
	
#Restart the Registry
#Restart the registry container to apply the changes:
sudo docker restart registry

#Step 8: Configure Authentication
#The config.yml file already includes authentication settings using the htpasswd file. Ensure the htpasswd file is correctly placed at /etc/docker/registry/htpasswd.

#Test Authentication
#Try accessing the registry without credentials:


curl http://localhost:5000/v2/

You should receive a 401 Unauthorized response.

Now, access the registry with credentials:


curl -u registry:yourpassword http://localhost:5000/v2/
Replace yourpassword with the password for the registry user. You should see {} as the response.

Step 9: Push and Pull Images
Tag an Image
Tag a local Docker image to point to your registry:


docker tag my-image localhost:5000/my-image

Push the Image
Push the image to your registry:


docker push localhost:5000/my-image

Pull the Image
Pull the image from your registry:


docker pull localhost:5000/my-image

Step 10: Access the Registry from Another Machine
To access the registry from another machine, replace localhost with the IP address of your registry server (e.g., 192.168.2.139).

Configure Docker to Trust the Registry
If you are using self-signed certificates, configure Docker to trust the registry:

Copy the domain.crt file to the client machine.

Place it in /etc/docker/certs.d/192.168.2.139:5000/ca.crt.


sudo mkdir -p /etc/docker/certs.d/192.168.2.139:5000
sudo cp /path/to/domain.crt /etc/docker/certs.d/192.168.2.139:5000/ca.crt

Restart Docker on the client machine:


sudo systemctl restart docker

Now, you can push/pull images using the registry's IP address:


docker tag my-image 192.168.2.139:5000/my-image
docker push 192.168.2.139:5000/my-image

Step 11: Backup and Maintenance
Backup the Registry Data:
Regularly back up the /var/lib/registry directory.


sudo tar -czvf registry-backup.tar.gz /var/lib/registry
Monitor Logs:
Check the registry logs for errors or issues:


sudo docker logs registry

Update the Registry:
Regularly update the Docker Registry image to the latest version:


sudo docker pull registry:2
sudo docker restart registry

Conclusion
You now have a fully functional Docker Registry with authentication and 
optional TLS encryption. You can use it to store and manage Docker images privately within your network. Regularly monitor and maintain the registry to ensure its security and performance.