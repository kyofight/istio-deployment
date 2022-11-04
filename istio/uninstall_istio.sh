#!/bin/bash

if [ -z "$REPO_HOME" ]
  then
    echo "No paths env is specified, source {project_root}/env.sh"
    exit 1
fi

helm delete --purge istio
helm delete --purge istio-init
helm delete --purge istio-cni
kubectl delete -f ${ISTIO_INSTALL_HOME}/install/kubernetes/helm/istio-init/files
kubectl label namespace default istio-injection-
# deleting namespace would delete pvc as well, to be decided?
kubectl delete namespace istio-system istio-init
