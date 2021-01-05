#!/bin/sh

helm version --short
if [ $? -gt 0 ]; then
    echo "Helm not found. Version 3 recomended. Checking for MicroK8s..."

    MHELMVERSION=$(microk8s helm3 version --short)
    if [ ! "${MHELMVERSION%%.*}" = "v3" ]; then
        echo "Helm 3 required. Exiting."
        exit 1
    else
        alias helm="microk8s helm3"
    fi
fi

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add stable https://charts.helm.sh/stable
helm repo update

helm install nginx-ingress ingress-nginx/ingress-nginx --set controller.service.type=NodePort --set controller.service.nodePorts.https=30443 --set controller.service.nodePorts.http=30080
sleep 15

echo "Installing Spinnaker."
cat <<YAML >> /tmp/values.yml
halyard:
  spinnakerVersion: 1.19.4

  additionalScripts:
    create: true
    data:
      configure.sh: |-
        export HAL_COMMAND="hal --daemon-endpoint http://spinnaker-spinnaker-halyard:8064"
        \$HAL_COMMAND config security api edit --override-base-url http://spinnaker-api.testthe.site
        \$HAL_COMMAND config security ui edit --override-base-url http://spinnaker.testthe.site

  additionalProfileConfigMaps:
    data:
      gate-local.yml:
        server:
          tomcat:
            protocolHeader: X-Forwarded-Proto
            remoteIpHeader: X-Forwarded-For
            internalProxies: .*
            httpsServerPort: X-Forwarded-Port

ingress:
  enabled: true
  host: spinnaker.testthe.site
  annotations:
    kubernetes.io/ingress.class: nginx
  http:
    paths:
    - path: /
      pathType: Prefix
      backend:
        service:
          name: spin-deck
          port:
            number: 9000

ingressGate:
  enabled: true
  host: spinnaker-api.testthe.site
  annotations:
    kubernetes.io/ingress.class: nginx
  http:
    paths:
    - path: /
      pathType: Prefix
      backend:
        service:
          name: spin-gate
          port:
            number: 8084
YAML

helm install --timeout 10m -f /tmp/values.yml spinnaker stable/spinnaker
