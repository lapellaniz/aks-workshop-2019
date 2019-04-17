# The Azure Kubernetes Workshop

- [Workshop Guide](https://aksworkshop.io/)
- [GitHub Gist](https://bit.ly/2VzfvRe)

## Setup

### Provision AKS

```powershell
$region="eastus"
$clusterName="aks-workshop-lra"
$kubernetesVersionLatest=$(az aks get-versions -l ${region} --query 'orchestrators[-1].orchestratorVersion' -o tsv)

az group create --name akschallenge --location $region

az aks create --resource-group akschallenge --name $clusterName --enable-addons monitoring --kubernetes-version $kubernetesVersionLatest --generate-ssh-keys --location $region

az aks get-credentials --resource-group akschallenge --name $clusterName
```

#### Grant Access to Dashboard

If using [RBAC](https://docs.microsoft.com/en-us/azure/aks/kubernetes-dashboard#for-rbac-enabled-clusters), a temporary approach to view the dashboard locally is to grant access to the service account.

*Consider using Azure AD*

```
kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard
```

####  Verify AKS Install

```
kubectl get nodes

az aks browse --resource-group akschallenge --name aks-workshop-lra
```

### Setup Helm

https://helm.sh/docs/using_helm/

#### Install Helm client locally

```
choco install kubernetes-helm
```

#### Deploy Helm to AKS

```
kubectl apply -f helm-rbac.yaml

helm init --service-account tiller
```

### Deploy Order Capture Mongo DB

```
helm install stable/mongodb --name orders-mongo --set mongodbUsername=orders-user,mongodbPassword=orders-password,mongodbDatabase=akschallenge
```

### Deploy Order Capture API

*update environment variables*

```
kubectl apply -f captureorder-deployment.yaml
```

#### Verify Order Capture API

```
kubectl get pods -l app=captureorder

kubectl logs -l app=captureorder

kubectl describe pod -l app=captureorder
```

#### Provision Order Capture Service

```
kubectl apply -f captureorder-service.yaml
```

##### Verify Order Capture Service

```
kubectl get service captureorder -o jsonpath="{.status.loadBalancer.ingress[*].ip}"

curl -d '{"EmailAddress": "email@domain.com", "Product": "prod-1", "Total": 100}' -H "Content-Type: application/json" -X POST http://[Your Service Public LoadBalancer IP]/v1/order
```

#### Provision Order Capture Ingress

*Update `CAPTUREORDERSERVICEIP` environment variable*

```
kubectl apply -f frontend-deployment.yaml
```

##### Verify Order Capture Ingress

```
kubectl get pods -l app=frontend
```

## Proctor Notes

```
az resource create --resource-group akschallenge --resource-type "Microsoft.Insights/components" --name akschallengeproctor --location eastus --properties '{\"Application_Type\":\"web\"}'

az resource show -g akschallenge -n akschallengeproctor --resource-type "Microsoft.Insights/components" --query properties.InstrumentationKey
```

Analytics

```
requests
| where success == "True"
| where customDimensions["team"] != "team-azch"
| summarize rps = count(id) by bin(timestamp, 1s), tostring(customDimensions["team"])
| summarize maxRPS = max(rps) by customDimensions_team
| order by maxRPS desc
| render barchart
```

### Add ACR Built-in Account as Kubernetes secret for ACR access

Use the Service Principal approach by defualt. If issues occur another approach is to use the built-in account that the container registry exposes.

```
az acr login -n acraksworkshoplra
az acr update -n acraksworkshoplra --admin-enabled true
az acr credential show -n acraksworkshoplra

kubectl create secret docker-registry acr-auth --docker-server acraksworkshoplra.azurecr.io --docker-username [docker_id] --docker-password [docker_secret] --docker-email [email]
```

## References

- [kubectl](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

