#__author__ = 'Munishpal Makhija'
#__email__ = 'munishpalmakhija@gmail.com'

#!/bin/bash


namespace_name=$1
values_file=$2
path=$3


echo "Namespace Name - "$1
echo "Values File - "$2
echo "Kubeconfig Path - "$3


export KUBECONFIG=$3

echo "Creating Namespace"

kubectl apply -f- << EOF
apiVersion: v1
kind: Namespace
metadata:
  name: $namespace_name
  labels:
    pod-security.kubernetes.io/enforce: privileged
EOF

sleep 2

echo "Creating Service Type LB"

kubectl apply -f- << EOF
apiVersion: v1
kind: Service
metadata:
  name: $namespace_name-lb
  namespace: $namespace_name
spec:
  selector:
    app: vcluster
    release: $namespace_name
  ports:
    - name: https
      port: 443
      targetPort: 8443
      protocol: TCP
  type: LoadBalancer
EOF

sleep 5

echo "Fetching External IP of Service Type LB"

external_ip=$(kubectl get svc $namespace_name-lb -n $namespace_name -o jsonpath="{.status.loadBalancer.ingress[0].ip}")

echo "External IP: "$external_ip

sleep 2

echo "Creating vCluster"

helm upgrade --install $namespace_name vcluster \
--values $values_file \
--repo https://charts.loft.sh \
--namespace $namespace_name \
--repository-config='' \
--set exportKubeConfig.server=https://$external_ip \
--set controlPlane.proxy.extraSANs={$external_ip} \
--version 0.24.0

echo "Still working on creating vCluster. Please wait......"

sleep 120

echo "Finished creating vCluster"

echo "Fetching Kubeconfig for vCluster"


kubectl get secret vc-$namespace_name -n $namespace_name --template={{.data.config}} | base64 -D

unset KUBECONFIG

