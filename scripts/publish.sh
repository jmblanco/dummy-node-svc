#!/bin/bash
REPO_NAME="dummy-node-svc"
IMAGE_TAG="1.0.0"
IMAGE_NAME="$REPO_NAME"
REGISTRY="localhost:5000"

echo "Creating oci image [$IMAGE_NAME:$IMAGE_TAG]"
docker build --no-cache -t "$IMAGE_NAME:$IMAGE_TAG" ..
docker tag "$IMAGE_NAME:$IMAGE_TAG" "$REGISTRY/$IMAGE_NAME:$IMAGE_TAG"

echo "Pushing docker image [$IMAGE_NAME:$IMAGE_TAG]"
docker push "$REGISTRY/$IMAGE_NAME:$IMAGE_TAG"
