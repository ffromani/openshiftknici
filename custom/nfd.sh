#!/bin/bash

CLUSTER_NAME=${1:-nfd-e2e}
KUBECONF=${2}

# kind does NOT support podman yet, so we hardcode docker
export IMAGE_BUILD_CMD="docker build"

# TODO: the extra tag name should be related to the CLUSTER_NAME,
# but the logic here works also with a hardcoded value, which we use
# to avoid quoting headaches.
IMAGE_EXTRA_TAG_NAMES=nfd-e2e make image

export IMAGE_REPO=$( docker images | awk '/nfd-e2e/ { print $1 }' | awk 'NR==1')
export IMAGE_TAG_NAME="nfd-e2e"
export NFD_IMAGE="${IMAGE_REPO}:${IMAGE_TAG_NAME}"

echo "built image: ${NFD_IMAGE} repo: ${IMAGE_REPO} tag: ${IMAGE_TAG_NAME}"

kind load docker-image --name ${CLUSTER_NAME} ${NFD_IMAGE}
# nfd >= 0.9.0
kind load docker-image --name ${CLUSTER_NAME} ${NFD_IMAGE}-minimal || :

KUBECONFIG=${KUBECONF} PULL_IF_NOT_PRESENT=true make e2e-test
