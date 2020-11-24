#!/bin/bash

set -u

BASEDIR=$( dirname $(readlink -f ${BASH_SOURCE[0]} ) )

export KUBECONFIG=$( ${BASEDIR}/../cluster/kind-replica1.sh start )
${BASEDIR}/../environment/topology-aware-scheduling-quick.sh start
$*
${BASEDIR}/../environment/topology-aware-scheduling-quick.sh stop
${BASEDIR}/../cluster/kind-replica1.sh stop
