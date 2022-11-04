#!/bin/bash

if [ -z "$REPO_HOME" ]
  then
    echo "No paths env is specified, {project_root}/env.sh"
    exit 1
fi

source ${REPO_HOME}/env.sh $env

cd ${KOPS_HOME}
terraform workspace select ${env}
terraform destroy
kops delete cluster --yes --state ${STATE} --name ${CLUSTER_NAME}

cd ${TERRAFORM_HOME}
terraform workspace select ${env}
terraform destroy
