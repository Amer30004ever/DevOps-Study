#!/bin/bash

# List of images to pull
IMAGES=(
#   "IMAGE:TAG" #add images
    "gamalm2041/myapp-gr18:v2.0"
    "prom/prometheus:latest"
    "amer30004ever/dinosaur-game:latest"
    "nginx:latest"
    "grafana/grafana:latest"
    "portainer/portainer-ce:latest"
    "quay.io/argoproj/argocd:v2.13.2"
    "mariadb:10.5"
    "amer30004ever/proj:latest"
    "httpd:latest"
    "registry:2"
    "docker.io/gitlab/gitlab-ce:latest"
    "docker.io/vaultwarden/server:latest"
    "jenkins/jenkins:lts"
    "kasten/k10:latest"
)

# Pull each image
for IMAGE in "${IMAGES[@]}"; do #expands the array into a list of its elements
    echo "Pulling $IMAGE..."
    docker pull "$IMAGE"
    if [ $? -eq 0 ]; then #if exit status equal 0(Successfull)
        echo "Successfully pulled $IMAGE"
    else #exit status equal 1(Failed)
        echo "Failed to pull $IMAGE"
    fi
    echo "----------------------------------------"
done

echo "All images pulled."
