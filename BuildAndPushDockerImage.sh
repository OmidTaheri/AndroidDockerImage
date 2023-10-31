#!/usr/bin/env bash
# Set your variables
image_name="android-docker"
tag="1.3.0"
dockerhub_username="XXXX"

# Build the Docker image
docker build -t "$dockerhub_username/$image_name" .

# Tag the image for Docker Hub
docker tag "$dockerhub_username/$image_name" "$dockerhub_username/$image_name:$tag"

# Log in to Docker Hub
docker login

# Push the image to Docker Hub
docker push "$dockerhub_username/$image_name:$tag"

# Logout from Docker Hub
docker logout
