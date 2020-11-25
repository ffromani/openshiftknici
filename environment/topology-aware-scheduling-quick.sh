#!/bin/bash

ACTION=${1}

DEVICE_PLUGIN_MANIFESTS="https://raw.githubusercontent.com/swatisehgal/sample-device-plugin/master/manifests"
TOPOLOGYAPI_MANIFESTS="https://raw.githubusercontent.com/swatisehgal/node-feature-discovery/rte"

if [ -z "${KUBECONFIG}" ]; then
	exit 1
fi

k8sdo() {
	echo "kubectl $*"
	kubectl $* || exit 2
}

start() {
	k8sdo create -f ${DEVICE_PLUGIN_MANIFESTS}/devicepluginA-ds.yaml
	k8sdo create -f ${DEVICE_PLUGIN_MANIFESTS}/devicepluginB-ds.yaml
	k8sdo create -f ${TOPOLOGYAPI_MANIFESTS}/crd.yaml
}

stop() {
	k8sdo delete -f ${TOPOLOGYAPI_MANIFESTS}/crd.yaml
	k8sdo delete -f ${DEVICE_PLUGIN_MANIFESTS}/devicepluginB-ds.yaml
	k8sdo delete -f ${DEVICE_PLUGIN_MANIFESTS}/devicepluginA-ds.yaml
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
	*)
		help
		exit 0
		;;
esac
