#!/usr/bin/env bash

IMAGE_OWNER="${IMAGE_OWNER:-dubodubonduponey}"
IMAGE_NAME="${IMAGE_NAME:-netatalk}"
IMAGE_VERSION="${IMAGE_VERSION:-v1}"
PLATFORMS="${PLATFORMS:-linux/amd64,linux/arm64,linux/arm/v7,linux/arm/v6}"

export DOCKER_CONTENT_TRUST=1
export DOCKER_CLI_EXPERIMENTAL=enabled
docker buildx create --name "$IMAGE_NAME"
docker buildx use "$IMAGE_NAME"
docker buildx build --platform "$PLATFORMS" -t "$IMAGE_OWNER/$IMAGE_NAME:$IMAGE_VERSION" --push .
