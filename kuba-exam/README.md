# Install k3s
```
curl -sfL https://get.k3s.io | sh -
```

# View tokern

```
sudo cat /var/lib/rancher/k3s/server/node-token

```
# Add node
run this code on worker node replace  ```myserver``` with your server ip and ```mynodetoken``` with your node token.
```
curl -sfL https://get.k3s.io | K3S_URL=https://myserver:6443 K3S_TOKEN=mynodetoken sh -
```

# Now set alias

It's help to shortcut for ```sudo kubectl```

```
alias k='sudo kubectl'
```

Now check node

```
k get nodes
```

1. Now create client manifest for client services and pods.


Apply the file & create client service and pods

```
 k apply -f client.yaml
```


2. Now create mongodb manifest for mongodb secret, script, service, pod & job.


Apply the file & create mongodb service, secret and pods.

```
 k apply -f mongodb-secret.yaml
 k apply -f mongodb-init-script.yaml
 k apply -f mongodb.yaml
 k apply -f mongodb-init-job.yaml
```


3. Now create server manifest for service and pods.

Apply the file & create server service and pods.

```
 k apply -f server.yaml
```

# Unistall k3s
For Master

```
sudo /usr/local/bin/k3s-uninstall.sh
```
For Agent
```
sudo /usr/local/bin/k3s-agent-uninstall.sh
```