# Configure AWS CLI

```
aws configure
```

# Configure the AWS Cluster from Local computer
```
aws eks update-kubeconfig --region us-east-1 --name master
```
 
# Create EBS

# Add addones on EKS
```
https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html
```

# Apply
```
kubectl apply -f mongo-secret.yaml

kubectl apply -f mongo-configmap.yaml

kubectl apply -f ebs-pv.yaml

kubectl apply -f ebs-pvc.yaml

kubectl apply -f mongo-deployment-ebs.yaml

kubectl apply -f mongo-deployment-ebs-svc.yaml
```

=============
# For Root User
=============

```
kubectl exec -it mongo-deployment-dffb86cd5-nschp mongosh
```

# Install mongosh on local Computer and connect to mongodb server

```
mongosh --username admin --password --authenticationDatabase admin --host mongodb-0.mongodb-svc.default.svc.cluster.local --port 27017
```

# Change database
```
use admin
```
=============
# Create User
=============

```
db.createUser(
  {
    user: "user1",
    pwd: "pass123",
    roles: [ { role: "userAdminAnyDatabase", db: "admin" }, "readWriteAnyDatabase" ]
  }
)
```
# Configure Database on applaction
```
const DB_USER = 'user1'
const DB_PASSWORD= 'pass123'
const DB_HOST= 'a59bdf0ac65fe4566a554d1e093bdff5-445085667.us-east-1.elb.amazonaws.com'
const DB_PORT='27017'
const DB_NAME='mydb'

const MONGO_URI = `mongodb://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}?authSource=admin`
```

=============
# Run Project
=============


# Follow the file apply on eks

1) mongo-secret.yaml
2) mongo-configmap.yaml
3) ebs-pv.yaml
4) ebs-pvc.yaml
5) mongo-deployment-ebs.yaml
6) mongo-deployment-ebs-svc.yaml

# This project run depend on this applaction
```
https://github.com/bjnandi/containerize-full-stack-app-MERN-with-docker-compose
```