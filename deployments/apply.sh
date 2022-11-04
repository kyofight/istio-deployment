#!/bin/bash

if [ -z "$REPO_HOME" ]
  then
    echo "No paths env is specified, source env.sh"
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


echo "******** apply configuration ********"
kubectl apply -f config

echo "******** apply secret ********"
kubectl apply -f secret

echo "######### applying $1 $2 #########"

EXISTS_NS=$(kubectl get ns | grep $1)
if [ -z "$EXISTS_NS" ]
  then
    echo ">>>>>>>> create namespace $1"
    kubectl create namespace $1
fi

if [ $1 != "logging" ] && [ $1 != "kube-system" ]
  then
    kubectl label namespace $1 istio-injection=enabled
fi

if [ $1 == "database" ] || [ $1 == "queue" ]
  then
    kubectl get pv
    read -p "Enter the pv name you want to bind (if none, just press enter): "  volume
    if [[ ! -z "$volume" ]]
      then
        echo "Volume name: ${volume}"
        kubectl patch pv $volume -p '{"spec":{"claimRef": null}}'
    fi

    cat $1/$2/values.yaml | envsubst | helm install --name $2 stable/$2 --namespace $1 --values -

    kubectl get pv
    read -p "Enter the pv name you want to patch to retain: "  volume
    if [[ ! -z "$volume" ]]
      then
        echo "Volume name: ${volume}"
        kubectl patch pv $volume -p '{"spec":{"persistentVolumeReclaimPolicy": "Retain"}}'
    fi

    cat $1/$2/traffic.yaml | envsubst | kubectl apply -f -
elif [ $1 == "kube-system" ] && [ $2 == "cluster-autoscaler" ]
  then
    cat $1/$2/values.yaml | envsubst | helm install --name $2 stable/$2 --namespace $1 --values -
elif [ $1 == "logging" ]
  then
    kubectl apply -f logging/elk-stacks/elasticsearch-client.yaml
    kubectl apply -f logging/elk-stacks/elasticsearch-data.yaml
    kubectl apply -f logging/elk-stacks/elasticsearch-master.yaml
#    sleep 5
#    while [[ $(kubectl get pods elasticsearch-data-0 -n logging -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for elasticsearch to be ready" && sleep 5; done
#    echo "wait 60 seconds for buffer"
#    sleep 60
#    ES_BOOTSTRAP_OUTPUT=$(kubectl exec -it $(kubectl get pods -n logging | grep elasticsearch-client | sed -n 1p | awk '{print $1}') -n logging -- bin/elasticsearch-setup-passwords auto -b)
#    echo "Elastic Search OUTPUT: ${ES_BOOTSTRAP_OUTPUT}"
#    export ES_USERNAME="elastic"
#    export ES_PASSWORD=$(echo $ES_BOOTSTRAP_OUTPUT | grep -o "PASSWORD ${ES_USERNAME} = [a-zA-Z0-9]*" | grep -o "[a-zA-Z0-9]*$")
#    export ELASTIC_SEARCH_USERNAME_SECRET=$(echo -n $ES_USERNAME | base64)
#    export ELASTIC_SEARCH_PASSWORD_SECRET=$(echo -n $ES_PASSWORD | base64)
#    cat logging/elk-stacks/elasticsearch-secret.yaml | envsubst | kubectl apply -f -
    kubectl apply -f logging/elk-stacks/kibana.yaml
    kubectl apply -f logging/elk-stacks/fluentd.yaml
    cat logging/elk-stacks/traffic.yaml | envsubst | kubectl apply -f -
elif [ $1 == "default" ] && [ $2 == "jenkins" ]
  then
    JENKINS_DOCKER_IMAGE=isuntv/jenkins
    JENKINS_DOCKER_TAG=latest
    if ! curl --silent -f -lSL https://index.docker.io/v1/repositories/${JENKINS_DOCKER_IMAGE}/tags/${JENKINS_DOCKER_TAG}; then
        docker build -t ${JENKINS_DOCKER_IMAGE}:${JENKINS_DOCKER_TAG} $1/$2
        docker push ${JENKINS_DOCKER_IMAGE}:${JENKINS_DOCKER_TAG}
    fi
    cat $1/$2/volume.yaml | envsubst | kubectl apply -f -
    cat $1/$2/jenkins.yaml | envsubst | kubectl apply -f -
    cat $1/$2/traffic.yaml | envsubst | kubectl apply -f -
else
    cat $1/$2/*.yaml | envsubst | kubectl apply -f -
fi
