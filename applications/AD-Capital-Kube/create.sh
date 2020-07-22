RESOURCE_GROUP=ad-capital-aks
CLUSTER_NAME=ad-capital

#if you don't have kubectl installed, you can run
#az acs kubernetes install-cli

az group create --name $RESOURCE_GROUP --location westeurope
az acs create --orchestrator-type kubernetes --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --generate-ssh-keys
az acs kubernetes get-credentials --resource-group=$RESOURCE_GROUP  --name=$CLUSTER_NAME
kubectl create -f ./Kubernetes --validate=false
az acs kubernetes browse --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME
