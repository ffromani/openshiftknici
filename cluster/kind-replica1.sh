#!/bin/bash

OPENSHIFTKNI_CI_KIND_IMAGE=${OPENSHIFTKNI_CI_KIND_IMAGE:-'kindest/node:v1.21.2@sha256:9d07ff05e4afefbba983fac311807b3c17a5f36e7061f6cb7e2ba756255b2be4'}

ACTION=${1}
CLUSTER_NAME=${2:-kni-test}
MASTER_NUM=${3:-1}
WORKER_NUM=${4:-1}

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
EOF

for idx in $( seq 1 $MASTER_NUM ); do
echo "- role: control-plane" >> ${CONTEXT}/kindconfig.yaml
done

for idx in $( seq 1 $WORKER_NUM ); do
echo "- role: worker" >> ${CONTEXT}/kindconfig.yaml
done

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
