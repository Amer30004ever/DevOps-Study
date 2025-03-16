#!/bin/bash

IMAGES=$(sudo crictl images -o json | jq -r '.images[] | "\(.repoTags[0]) \(.id)"')

for IMAGE in $IMAGES; do
    IMAGE_NAME=$(echo $IMAGE | awk '{print $1}')
    IMAGE_ID=$(echo $IMAGE | awk '{print $2}')
    TAR_FILE=$(echo $IMAGE_NAME | tr '/' '_' | tr ':' '_').tar
    echo "Exporting $IMAGE_NAME to $TAR_FILE..."
    sudo ctr -n k8s.io images export $TAR_FILE $IMAGE_NAME
done