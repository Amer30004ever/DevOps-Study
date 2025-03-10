###Step 1: Configure Docker to Allow Insecure Registries
##Edit the Docker daemon configuration file:

#Open or create the Docker daemon configuration file, 
#typically located at /etc/docker/daemon.json.
sudo vi /etc/docker/daemon.json

#Add the following configuration to allow insecure communication with your registry:

{
  "insecure-registries": ["192.168.2.139:5000"]
}

#Save and close the file.

##Restart the Docker daemon:

#After modifying, restart the Docker daemon to apply changes:
sudo systemctl restart docker

sudo systemctl status docker
#● docker.service - Docker Application Container Engine
#     Loaded: loaded (/lib/systemd/system/docker.service; enabled; vendor preset: enabled)
#     Active: active (running) since Mon 2025-02-24 13:06:08 UTC; 10s ago

###Step 2: Verify the Configuration
##Check if the insecure-registries setting is applied:

docker info | grep Insecure

##You should see something like:

Insecure Registries:
  192.168.2.139:5000
###Step 3: Retry Pushing the Image

#Check images:
docker image ls

##Tag the image (if not already done):

docker tag gamalm2041/myapp-gr18:v2.0 192.168.2.139:5000/gamalm2041/myapp-gr18:v2.0
docker tag amer30004ever/dinosaur-game:latest 192.168.2.139:5000/amer30004ever/dinosaur-game:latest
docker tag gcr.io/k8s-minikube/kicbase:v0.0.46 192.168.2.139:5000/kicbase:v0.0.46

#Check images:
docker image ls

REPOSITORY                    TAG       IMAGE ID       CREATED       SIZE
gamalm2041/myapp-gr18         v2.0      e54c7bef240c   3 days ago    172MB
amer30004ever/dinosaur-game                latest    b56ecfea73c0   8 days ago    50.5MB
gcr.io/k8s-minikube/kicbase                v0.0.46   e72c4cbe9b29   5 weeks ago   1.31GB

#The tagged images will apear like
REPOSITORY                                 TAG       IMAGE ID       CREATED       SIZE
192.168.2.139:5000/gamalm2041/myapp-gr18   v2.0      e54c7bef240c   3 days ago    172MB
192.168.2.139:5000/amer30004ever/dinosau   latest    b56ecfea73c0   8 days ago    50.5MB
r-game
192.168.2.139:5000/kicbase                 v0.0.46   e72c4cbe9b29   5 weeks ago   1.31GB
gamalm2041/myapp-gr18                      v2.0      e54c7bef240c   3 days ago    172MB
amer30004ever/dinosaur-game                latest    b56ecfea73c0   8 days ago    50.5MB
gcr.io/k8s-minikube/kicbase                v0.0.46   e72c4cbe9b29   5 weeks ago   1.31GB

###Important Note
#Docker does not create a new image. Instead, it creates a new tag that points 
#to the same underlying image (with the same IMAGE ID). This is why you see the 
#same IMAGE ID for both gamalm2041/myapp-gr18:v2.0 and 192.168.2.139:5000/gamalm2041/myapp-gr18:v2.0 
#in your docker image ls output.

##Push the image:
docker push 192.168.2.139:5000/gamalm2041/myapp-gr18:v2.0

##Verify the Push
#After pushing, verify that the images are in your registry.

#List all repositories:
curl http://192.168.2.139:5000/v2/_catalog
#output:
{"repositories":["amer30004ever/dinosaur-game", "kicbase", "gamalm2041/myapp-gr18"]}

##List tags for each repository:

#For amer30004ever/dinosaur-game:
curl http://192.168.2.139:5000/v2/amer30004ever/dinosaur-game/tags/list
#output:
{"name":"amer30004ever/dinosaur-game","tags":["latest"]}

#For kicbase:
curl http://192.168.2.139:5000/v2/kicbase/tags/list
#output:
{"name":"kicbase","tags":["v0.0.46"]}

###Step 4: Clean Up Local Tags (Optional)
#If you no longer need the local tags, you can remove them to clean up your docker image ls output.


#Remove the local tag for amer30004ever/dinosaur-game & kicbase::
docker rmi 192.168.2.139:5000/amer30004ever/dinosaur-game:latest
docker rmi 192.168.2.139:5000/kicbase:v0.0.46

#Note: This only removes the tag, not the underlying image, as long as other tags 
#(e.g., amer30004ever/dinosaur-game:latest) still reference it.