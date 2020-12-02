#!/bin/bash

set -u

OPENSHIFTKNI_CI_KIND_IMAGE=${OPENSHIFTKNI_CI_KIND_IMAGE:-'kindest/node:v1.19.1@sha256:98cf5288864662e37115e362b23e4369c8c4a408f99cbc06e58ac30ddc721600'}
DEVICE_PLUGIN_MANIFESTS="https://raw.githubusercontent.com/swatisehgal/sample-device-plugin/master/manifests"
TOPOLOGYAPI_MANIFESTS="https://raw.githubusercontent.com/swatisehgal/node-feature-discovery/rte"

CLUSTER_NAME=${1:-kni-test}

which kind &> /dev/null || exit 1

CONTEXT=$( mktemp -d $(pwd)/knici-${CLUSTER_NAME}-XXXXXXXXXX )
kind version > ${CONTEXT}/kindversion
echo ${OPENSHIFTKNI_CI_KIND_IMAGE} > ${CONTEXT}/kindimage
cat > ${CONTEXT}/kindconfig.yaml << EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
kubeadmConfigPatches:
- |
  kind: KubeletConfiguration
  cpuManagerPolicy: "static"
  cpuManagerReconcilePeriod: "5s"
  topologyManagerPolicy: "single-numa-node"
  reservedSystemCPUs: "1"
nodes:
- role: control-plane
- role: worker
EOF

RET=127
cleanup() {
	# add here only scripts which DON'T depend on env vars
	kind delete cluster --name ${CLUSTER_NAME}
	exit ${RET}
}

kind create cluster \
	--kubeconfig ${CONTEXT}/kubeconfig \
	--config ${CONTEXT}/kindconfig.yaml \
	--image ${OPENSHIFTKNI_CI_KIND_IMAGE} \
	--name ${CLUSTER_NAME} || exit 2
trap cleanup SIGINT SIGTERM ERR EXIT

kubectl label node kind-worker node-role.kubernetes.io/worker=''

export KUBECONFIG="${CONTEXT}/kubeconfig"

kubectl create -f ${DEVICE_PLUGIN_MANIFESTS}/devicepluginA-ds.yaml
kubectl create -f ${DEVICE_PLUGIN_MANIFESTS}/devicepluginB-ds.yaml
kubectl create -f ${TOPOLOGYAPI_MANIFESTS}/manifests/noderesourcetopologies.yaml.template
# TODO wait for the daemonset to go running

# kind does NOT support podman yet, so we hardcode docker
export IMAGE_BUILD_CMD="docker build"

IMAGE_EXTRA_TAG_NAMES=nfd-e2e make image

export IMAGE_REPO=$( docker images | awk '/nfd-e2e/ { print $1 }' )
export IMAGE_TAG_NAME="nfd-e2e"
export NFD_IMAGE="${IMAGE_REPO}:${IMAGE_TAG_NAME}"

kind load docker-image --name ${CLUSTER_NAME} ${NFD_IMAGE}

KUBECONFIG=${KUBECONFIG} PULL_IF_NOT_PRESENT=true make e2e-test
RET="$?"
