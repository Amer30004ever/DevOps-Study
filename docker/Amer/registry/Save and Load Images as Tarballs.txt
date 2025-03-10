docker image ls
#REPOSITORY                                       TAG       IMAGE ID       CREATED       SIZE
#gamalm2041/myapp-gr18                            v2.0      e54c7bef240c   3 days ago    172MB
#amer30004ever/dinosaur-game                      latest    b56ecfea73c0   9 days ago    50.5MB
#gcr.io/k8s-minikube/kicbase                      v0.0.46   e72c4cbe9b29   6 weeks ago   1.31GB

##Use docker save and docker load
#If you want to avoid tagging altogether, you can use docker save to expor 
#the image as a compressed file and then use docker load to import it on another machine. 
#However, this is not as efficient as using a registry.
#Export the image:

docker save gamalm2041/myapp-gr18:v2.0 -o myapp-gr18-v2.0.tar
docker save amer30004ever/dinosaur-game:latest -o dinosaur-game-latest.tar
docker save gcr.io/k8s-minikube/kicbase:v0.0.46 -o kicbase-v0.0.46.tar

##Transfer the Tarballs
#Transfer the tarball to the target machine (e.g., using scp).

sudo scp myapp-gr18-v2.0.tar registry@192.168.2.139:/home/registry
sudo scp dinosaur-game-latest.tar registry@192.168.2.139:/home/registry
sudo scp kicbase-v0.0.46.tar registry@192.168.2.139:/home/registry

#Import the image on the target machine:

docker load -i myapp-gr18-v2.0.tar
docker load -i dinosaur-game-latest.tar
docker load -i kicbase-v0.0.46.tar

#Show images:
docker image ls