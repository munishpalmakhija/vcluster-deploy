# vcluster-deploy
 Configs to deploy vCluster on VKS

# vCluster Deploy

This repo contains script and the config files to provision virutal K8s clusters a.k.a. vClusters.

# Pre-requisities

## Tools

Following tools are required before executing the script 

1. kubectl
2. helm

## Config Files
You will need to reach out to Tanzu Platform Infra Team to get following config files 

1. Kubeconfig - To access the management K8s cluster were vClusters will be provisioned.
2. Values File - To specify the vCluster configuration like K8s version, Workers to be used.


# Script Execution

Here's a list of recommended steps.

## Step 1 - Export required environment Variables

You will need to export 3 environment variables

```
export namespace_name=vcluster-automation-demo
export values_file=tpe-vcluster-values.yaml (You can modify based on you requirement in case you have any node selectors)
export KUBECONFIG=VKS-Cluster-Admin-Kubeconfig (This will be the host VKS cluster where vClusters will be created )
```

## Step 2 - Execute bash script

Execute the bash script create_vcluster.sh

```
bash create_vcluster.sh $namespace_name $values_file $KUBECONFIG
```

It performs following 

1. Create Namespace
2. Create K8 service with Type LoadBalancer
3. Deploys vcluster statefulset using helm with K8s version 1.32.1using default K8s distro 
4. It enables following inside vcluster
   - Coredns server
   - Metrics
   - Storage Class
   - K8s events

# Delete vCluster

Once you are done validating you can delete the namespace where vCluster was provisioned to delete the vCluster

```
kubectl delete ns $namespace_name
```

