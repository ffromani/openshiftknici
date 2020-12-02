#!/bin/bash

BASEDIR=$( dirname $(readlink -f ${BASH_SOURCE[0]} ) )
STOPACTION="stop"
RET=127

cleanup() {
	# add here only scripts which DON'T depend on env vars
	${BASEDIR}/../environment/topology-aware-scheduling-quick.sh ${STOPACTION}
	${BASEDIR}/../cluster/kind-replica1.sh stop nfd-e2e
	exit ${RET}
}

if [ -z "${KUBECONFIG}" ]; then
	export KUBECONFIG=$( ${BASEDIR}/../cluster/kind-replica1.sh start nfd-e2e )
else
	STOPACTION=pass
fi
trap cleanup SIGINT SIGTERM ERR EXIT

${BASEDIR}/../environment/topology-aware-scheduling-quick.sh start
${BASEDIR}/../custom/nfd.sh nfd-e2e ${KUBECONFIG}
RET="$?"
exit ${RET}
