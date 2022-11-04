#!/bin/bash

if [ -z "$REPO_HOME" ]
  then
    echo "No paths env is specified, {project_root}/env.sh"
    exit 1
fi

echo ">>> init"
cd ${TERRAFORM_HOME}
terraform init
terraform workspace new ${env}
terraform workspace select ${env}
terraform plan
terraform apply || true

source ${REPO_HOME}/env.sh $env

echo ">>> kops generate terraform files"
cd ${KOPS_HOME}
terraform init
kops toolbox template --name ${CLUSTER_NAME} --values <( echo ${TF_OUTPUT}) --template "cluster-template-${env}.yaml" --format-yaml > cluster.yaml
kops replace -f cluster.yaml --state ${STATE} --name ${CLUSTER_NAME} --force
kops create secret --name ${CLUSTER_NAME} --state ${STATE} sshpublickey admin -i ~/.ssh/id_rsa.pub
kops update cluster --target terraform --state ${STATE} --name ${CLUSTER_NAME} --out .
rm -f versions.tf
terraform 0.12upgrade

echo ">>> terraform kops apply"
terraform workspace new ${env}
terraform workspace select ${env}
terraform plan
terraform apply

