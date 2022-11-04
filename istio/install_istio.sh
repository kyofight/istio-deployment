#!/bin/bash

if [ -z "$REPO_HOME" ]
  then
    echo "No paths env is specified, source {project_root}/env.sh"
    exit 1
fi


echo "install tiller"
# prepare helm
kubectl -n kube-system create serviceaccount tiller
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller

# wait for tiller to be ready, use a better checking instead of sleep
echo "waiting tiller to be ready......"
helm init --wait --service-account tiller
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'

echo "create docker credential for istio pull secrets"
docker login
kubectl create secret generic regcred \
    --from-file=.dockerconfigjson="${HOME}/.docker/config.json" \
    --type=kubernetes.io/dockerconfigjson


source ${REPO_HOME}/env.sh $env

echo "installing istio, guide: https://medium.com/@petr.ruzicka/istio-in-amazon-eks-23704aef4f28"
cd ~
curl -sL https://git.io/getLatestIstio | sh -
cd istio-${ISTIO_VERSION}
test -x /usr/local/bin/istioctl || sudo mv bin/istioctl /usr/local/bin/
echo "1. init istio"
helm install install/kubernetes/helm/istio-init --wait --name istio-init --namespace istio-system \
    --set certmanager.enabled=true

cat ${ISTIO_HOME}/addon_secret.yaml | envsubst | kubectl apply -f -

sleep 30

echo "2. install istio"
cat ${ISTIO_HOME}/istio_helm_values.yaml | envsubst | helm install ${ISTIO_INSTALL_HOME}/install/kubernetes/helm/istio --wait \
    --name istio --namespace istio-system --values -

sleep 30

echo "setting aws route53 config"
export LOADBALANCER_HOSTNAME=$(kubectl get svc istio-ingressgateway -n istio-system -o jsonpath="{.status.loadBalancer.ingress[0].hostname}")
export CANONICAL_HOSTED_ZONE_NAME_ID=$(aws elb describe-load-balancers --region=${REGION} --query "LoadBalancerDescriptions[?DNSName==\`$LOADBALANCER_HOSTNAME\`].CanonicalHostedZoneNameID" --output text)
export HOSTED_ZONE_ID=$(aws route53 list-hosted-zones --query "HostedZones[?Name==\`${DOMAIN_NAME}.\`].Id" --output text)
cat << EOF | aws route53 change-resource-record-sets --hosted-zone-id ${HOSTED_ZONE_ID} --change-batch=file:///dev/stdin
{
    "Comment": "A new record set for the zone.",
    "Changes": [
      {
        "Action": "UPSERT",
        "ResourceRecordSet": {
          "Name": "*.${DOMAIN_NAME}.",
          "Type": "A",
          "AliasTarget":{
            "HostedZoneId": "${CANONICAL_HOSTED_ZONE_NAME_ID}",
            "DNSName": "dualstack.${LOADBALANCER_HOSTNAME}",
            "EvaluateTargetHealth": false
          }
        }
      },
      {
        "Action": "UPSERT",
        "ResourceRecordSet": {
          "Name": "${DOMAIN_NAME}.",
          "Type": "A",
          "AliasTarget":{
            "HostedZoneId": "${CANONICAL_HOSTED_ZONE_NAME_ID}",
            "DNSName": "dualstack.${LOADBALANCER_HOSTNAME}",
            "EvaluateTargetHealth": false
          }
        }
      }
    ]
}
EOF

echo "apply istio networking for addons"
cd ${ISTIO_HOME}
cat addon_traffic.yaml | envsubst | kubectl apply -f -