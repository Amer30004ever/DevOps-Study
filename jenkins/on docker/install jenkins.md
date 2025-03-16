# Pull and run Jenkins
    docker pull jenkins/jenkins
	sudo mkdir -p /mnt/jenkins/data
    docker run -d --name jenkins --restart always -p 7000:8080 jenkins/jenkins