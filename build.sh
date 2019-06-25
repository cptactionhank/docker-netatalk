#!/usr/bin/env bash

IMAGE_OWNER=dubodubonduponey
IMAGE_NAME=netatalk
IMAGE_VERSION=v1

export DOCKER_CLI_EXPERIMENTAL=enabled
docker buildx create --name "$IMAGE_NAME"
docker buildx use "$IMAGE_NAME"

docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7,linux/arm/v6 -t "$IMAGE_OWNER/$IMAGE_NAME:$IMAGE_VERSION" --push .
