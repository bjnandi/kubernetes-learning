# Remove all resource using variable

Create resouree
```
Make all_resources
```
Delete resouree
```
Make delete_resources
```
Now login the HostPC

Login the host pc using Key.pem file
```
ssh -i "Key.pem" ubuntu@18.232.166.117
```

Then login  master from Host pc becouse host pc not public ip

Copy Key.pem to HostPC

Change the permission of key file
```
chmod 400 key.pem
```
Login the Master
```
ssh -i "Key.pem" ubuntu@10.0.2.190
```
