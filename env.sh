#!/bin/bash

if [ -z "$1" ]
  then
    echo "No env is specified"
    exit 1
fi

export env=$1
export REPO_HOME=~/server-deployment
export K8S_HOME="${REPO_HOME}/k8s"
export TERRAFORM_HOME="${K8S_HOME}/terraform"
export KOPS_HOME="${K8S_HOME}/kops"
export ISTIO_HOME="${REPO_HOME}/istio"
export ADDON_HOME="${REPO_HOME}/addons"
export ISTIO_VERSION="1.4.2"

if [ -d "${TERRAFORM_HOME}/.terraform" ]
  then
    export TF_OUTPUT=$(cd ${TERRAFORM_HOME} && terraform output -json)
    export CLUSTER_NAME="$(echo ${TF_OUTPUT} | jq -r .kubernetes_cluster_name.value)"
    export STATE="s3://$(echo ${TF_OUTPUT} | jq -r .kops_s3_bucket.value)"
    export ZONES="$(echo ${TF_OUTPUT} | jq -r '.availability_zones.value | join(",")')"
    export DOMAIN_NAME=$(echo ${TF_OUTPUT} | jq -r .domain_name.value)
    export REGION=$(echo ${TF_OUTPUT} | jq -r .region.value)
    export ISTIO_INSTALL_HOME="${HOME}/istio-${ISTIO_VERSION}"
fi
