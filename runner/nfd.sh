#!/bin/bash

set -u

BASEDIR=$( dirname $(readlink -f ${BASH_SOURCE[0]} ) )

export KUBECONFIG=$( ${BASEDIR}/../cluster/kind-replica1.sh start nfd-e2e )
${BASEDIR}/../environment/topology-aware-scheduling-quick.sh start
${BASEDIR}/../custom/nfd.sh nfd-e2e ${KUBECONFIG}
${BASEDIR}/../environment/topology-aware-scheduling-quick.sh stop
${BASEDIR}/../cluster/kind-replica1.sh stop nfd-e2e
