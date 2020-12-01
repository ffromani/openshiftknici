#!/bin/bash

# kind does NOT support podman yet, so we hardcode docker
export IMAGE_BUILD_CMD="docker build"

make image

export NFD_IMAGE=$( docker images --format "{{.ID}}" | head -n1 )
export IMAGE_REPO=$( echo "${NFD_IMAGE}" | cut -d: -f1 )
export IMAGE_TAG_NAME=$( echo "${NFD_IMAGE}" | cut -d: -f1 )

echo "built image: ${NFD_IMAGE} repo: ${IMAGE_REPO} tag: ${IMAGE_TAG_NAME}"

kind load docker-image "${NFD_IMAGE}"

make e2e-test
