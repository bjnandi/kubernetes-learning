# Install helm package
```
helm install postgresql bitnami/postgresql -f values.yaml
```
# Uninstall helm package
```
helm uninstall postgresql
```
 <hr>
 
# Helm chart install

Step 1: Install Helm chart

Step 2: Create Helm chart

```
helm create myapp
```

Step 3: Edit values.yaml

Step 4: Install chart or package
```
helm install myappname myapp
```

Step 5: Check helm chart list
```
helm list
```

Step 6: Check service
```
kubectl get service
```

Step 7: Check service
```
http://<Public_IP>:portnumber
```
---------------------------------------------------------------------------
```Set``` command is use for update value ```helm chart``` value in package
```
--set
```

 ```
--set server.service.type=LoadBalancer
 ```

Reference
```
https://medium.com/@vijayalakshmiyvl/deploy-your-first-helm-chart-in-kubernetes-cluster-20f5e33e58b6
```


```
helm list -n monitoring
```
```
helm show values prometheus-community/prometheus-nginx-exporter
```
