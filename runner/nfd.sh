#!/bin/bash

BASEDIR=$( dirname $(readlink -f ${BASH_SOURCE[0]} ) )

CLUSTER_NAME=${1:-nfd-e2e}

STOPACTION="stop"
RET=127


cleanup() {
	# add here only scripts which DON'T depend on env vars
	${BASEDIR}/../environment/topology-aware-scheduling-quick.sh ${STOPACTION}
	${BASEDIR}/../cluster/kind-replica1.sh stop ${CLUSTER_NAME}
	exit ${RET}
}

if [ -z "${KUBECONFIG}" ]; then
	export KUBECONFIG=$( ${BASEDIR}/../cluster/kind-replica1.sh start ${CLUSTER_NAME} )
else
	STOPACTION=pass
fi
trap cleanup SIGINT SIGTERM ERR EXIT

${BASEDIR}/../environment/topology-aware-scheduling-quick.sh start
${BASEDIR}/../custom/nfd.sh ${CLUSTER_NAME} ${KUBECONFIG}
RET="$?"
exit ${RET}
