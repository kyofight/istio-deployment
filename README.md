## Environment Setup For AWS

#### 1. server setup
    1. create a server with Debian architecture (e.g. ubuntu) with low tier (e.g. aws micro)
        - attach "ec2 full access" and "s3 full / partial access" to the server
    2. create an iam role with following permissions and attach to the server (for aws only, other cloud service may vary)
        - AmazonEC2FullAccess
        - AmazonRoute53FullAccess
        - AmazonS3FullAccess
        - IAMFullAccess
        - AmazonVPCFullAccess
    3. ssh -i "key.pem" user@server

#### 2. dependencies installation
    1. cd ~
    2. git clone https://bitbucket.org/kyo/server-deployment
    3. cd ~/server-deployment
    4. git checkout master
    5. chmod +x **/\*.sh
    6. ./init.sh

#### 3. create two buckets for terraform state
    - server.terraform.k8s
        - region "ap-southeast-1"
    - server.terraform
        - region "ap-southeast-1"

## Cluster Management

#### Create Cluster
    1. cd ~/server-deployment/k8s
    2. ssh-keygen
        - Note: generate ~/.ssh/id-rsa.pub
    3. ./k8s/prepare_resources.sh
        
#### Update Cluster
    1. cd ~/server-deployment/k8s
    2. ./prepare_resources.sh
    3. kops rolling-update cluster --yes --state ${STATE} --name ${CLUSTER_NAME}
    
#### Destroy Cluster
    1. cd ~/server-deployment/k8s
    2. ./k8s/destroy_resources.sh
        - NOTE: there maybe some dangling resources, run it again after a while
    
#### Edit Cluster settings
    - k8s/terraform/main.tf
    - k8s/terraform/env_variables.tf
    - k8s/terraform/terraform_state.tf
    - k8s/kops/terraform_state.tf
    - k8s/kops/*.yaml

## Istio

#### Install
    1. cd ~/server-deployment/istio
    2. ./install_istio.sh [version]
        - default version is 1.4.2
        - istio installation options is in istio/istio_values.yaml
            - for values of each chart, refer to the official repo
            
#### Uninstall
    1. cd ~/server-deployment/istio
    2. ./uninstall_istio.sh

## Uninstall Cluster Addons    
    1. helm del --purge {name}
        - helm list to find out addon names
    2. kubectl delete namespace {namespace of the addons}
            - optional step   

## Deployment
    1. cd ~/server-deployment/deployments
    2. cat **/*.yaml | envsubst | kubectl apply -f -
        - delete: kubectl delete -f services/blobvault.yaml
        - apply: cat services/blobvault.yaml | envsubst | kubectl apply -f -
        
        
        kubectl apply -f config
        kubectl get gateway,virtualservice,destinationrule
        cat config/*.yaml | envsubst | kubectl apply -f -
        cat services/*.yaml | envsubst | kubectl apply -f -
        
        cat services/notifier.yaml | envsubst | kubectl apply -f -
        cat services/dataapi.yaml | envsubst | kubectl apply -f -
        cat services/rpc.yaml | envsubst | kubectl apply -f -
        cat services/blobvault.yaml | envsubst | kubectl apply -f -
        cat services/authd.yaml | envsubst | kubectl apply -f -
        
        cat services/social-community-api.yaml | envsubst | kubectl apply -f -
        cat services/social-community-socket.yaml | envsubst | kubectl apply -f -
        cat services/social-community-notifier.yaml | envsubst | kubectl apply -f -
        
        cat logging/traffic.yaml | envsubst | kubectl apply -f -
        
        cat addon_traffic.yaml | envsubst | kubectl apply -f -
        
        cat database/mysql/*.yaml | envsubst | kubectl apply -f -
        
        cat helm/database/mongodb/traffic.yaml | envsubst | kubectl apply -f -
        
        cat logging/*.yaml | envsubst | kubectl apply -f -
        
        cat addon_networking.yaml | envsubst | kubectl apply -f -
        kubectl delete -f services/authd.yaml

## Addons

#### Install
    1. cd ~/server-deployment/istio
    2. ./install_istio.sh [version]
        - default version is 1.4.2
        - istio installation options is in istio/istio_install_values.yaml
            - for values of each chart, it can be found in install/kubernetes/helm/istio/charts/{chart name}/values.yaml

#### Upgrade Istio
    - cat ${ISTIO_HOME}/istio_helm_values.yaml | envsubst | helm upgrade istio ${ISTIO_INSTALL_HOME}/install/kubernetes/helm/istio -f -
            
           
#### Uninstall
    1. cd ~/server-deployment/istio
    2. ./uninstall_istio.sh

## Useful commands
    init command: source ~/server-deployment/k8s/env.sh
    - kubectl describe nodes
    - kops validate cluster --state ${STATE} --name ${CLUSTER_NAME}
    - kops delete cluster --yes --state ${STATE} --name ${CLUSTER_NAME}
    - kops get clusters --state ${STATE}
    - kops edit cluster ${CLUSTER_NAME} --state ${STATE}
    - kops get --state ${STATE} --name ${CLUSTER_NAME} -oyaml
    - kops update cluster --yes --state ${STATE} --name ${CLUSTER_NAME}
    - kops rolling-update cluster --yes --state ${STATE} --name ${CLUSTER_NAME}
    - kops get instancegroups --state ${STATE}
    - kops edit ig nodes --state ${STATE}
