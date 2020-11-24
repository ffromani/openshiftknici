#!/bin/bash

ACTION=${1}

DEVICE_PLUGIN_MANIFESTS="https://raw.githubusercontent.com/swatisehgal/sample-device-plugin/master/manifests"
TOPOLOGYAPI_MANIFESTS="https://raw.githubusercontent.com/swatisehgal/node-feature-discovery/rte"

if [ -z "${KUBECONFIG}" ]; then
	exit 1
fi

start() {
	kubectl create -f ${DEVICE_PLUGIN_MANIFESTS}/devicepluginA-ds.yaml || exit 2
	kubectl create -f ${DEVICE_PLUGIN_MANIFESTS}/devicepluginB-ds.yaml || exit 2
	kubectl create -f ${TOPOLOGYAPI_MANIFESTS}/crd.yaml || exit 2
}

stop() {
	kubectl delete -f ${TOPOLOGYAPI_MANIFESTS}/crd.yaml || exit 2
	kubectl delete -f ${DEVICE_PLUGIN_MANIFESTS}/devicepluginB-ds.yaml || exit 2
	kubectl delete -f ${DEVICE_PLUGIN_MANIFESTS}/devicepluginA-ds.yaml || exit 2
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
