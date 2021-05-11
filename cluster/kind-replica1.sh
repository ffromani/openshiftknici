#!/bin/bash

OPENSHIFTKNI_CI_KIND_IMAGE=${OPENSHIFTKNI_CI_KIND_IMAGE:-'kindest/node:v1.19.1@sha256:98cf5288864662e37115e362b23e4369c8c4a408f99cbc06e58ac30ddc721600'}

ACTION=${1}
CLUSTER_NAME=${2:-kni-test}

which kind &> /dev/null || exit 1

start() {
	if [ -n "${KUBECONFIG}" ]; then
		echo "${KUBECONFIG}"
		exit 0
	fi

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
  featureGates:
    KubeletPodResourcesGetAllocatable: true
nodes:
- role: control-plane
- role: worker
EOF
	kind create cluster \
		--kubeconfig ${CONTEXT}/kubeconfig \
		--config ${CONTEXT}/kindconfig.yaml \
		--image ${OPENSHIFTKNI_CI_KIND_IMAGE} \
		--name ${CLUSTER_NAME} || exit 2
	kubectl label node ${CLUSTER_NAME}-worker node-role.kubernetes.io/worker=''
	echo "${CONTEXT}/kubeconfig"
}

stop() {
	kind delete cluster \
		--name ${CLUSTER_NAME} || exit 2
}

help() {
	echo "help: $0 start|stop [cluster_name]"
}

case $ACTION in
	start)
		start
		;;
	stop)
		stop
		;;
	pass)
		# do nothing, successfully
		exit 0
		;;
	*)
		help
		exit 0
		;;
esac
