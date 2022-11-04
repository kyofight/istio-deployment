#!/bin/bash

if [ -z "$REPO_HOME" ]
  then
    echo "No paths env is specified, source {project_root}/env.sh"
    exit 1
fi

if [ -z "$1" ]
  then
    echo "No namespace is specified"
    exit 1
fi

if [ -z "$2" ]
  then
    echo "No service is specified"
    exit 1
fi

echo "######### deleting $1 $2 #########"

if [ $1 == "database" ] || [ $1 == "queue" ] || [ $1 == "kube-system" ]
  then
    helm del --purge $2
    kubectl delete -f $1/$2/traffic.yaml
elif [ $1 == "default" ] && [ $2 == "jenkins" ]
  then
    kubectl delete -f $1/$2/jenkins.yaml
    kubectl delete -f $1/$2/traffic.yaml
  else
    kubectl delete -f $1/$2
fi



echo ">>>>>>>> be sure to delete the persistent volumes in volumes folder if necessary, or delete the namespace once for all"
