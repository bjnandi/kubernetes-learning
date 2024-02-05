# Ingress Controller
Step 1: Add repo
```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
```
Step 2: Install Ingress Controller
```
helm upgrade --install ingress-nginx ingress-nginx  --repo https://kubernetes.github.io/ingress-nginx  --namespace ingress-nginx --create-namespace
```

Step 3: Verify if the Ingress Controller Pods are created
```
kubectl get all -n ingress-nginx
```
Step 4: Deploy Pod, Service & Ingress
```
kubectl apply -f https://raw.githubusercontent.com/bjnandi/kubernetes-learning/main/eks/nwujobs-app.yaml
```
Step 5: Check Pod, Service & Ingress

```
kubectl get all
```
Step 6: Add ingress-nginx-controller EXTERNAL-IP to dns server

Step 7: browser domain fort the service
```
http://nwujobs.bjtechlife.com/
``` 