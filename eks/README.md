# Create Cluster

```
eksctl create cluster -f cluster.yaml
```

# Delete Cluster
```
eksctl delete cluster -f cluster.yaml
```
# Cluster configure on vscode

```
aws eks update-kubeconfig  --name claster_name
```