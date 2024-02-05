# It use only for Public Network and Instances

#!/bin/bash

# Create VPC ===========================================================
# Variables
vpc_name="MyVPC"
cidr_block="10.0.0.0/16"

vpc_id=$(aws ec2 create-vpc --cidr-block $cidr_block --output json | jq -r '.Vpc.VpcId')

# Add a name tag to the VPC
aws ec2 create-tags --resources $vpc_id --tags Key=Name,Value=$vpc_name

echo "VPC $vpc_name created with ID: $vpc_id"


# Create Subnet =======================================================
# Variables
subnet_name="MySubnet"
cidr_block="10.0.0.0/24"
availability_zone="us-east-1a"  # replace with your desired availability zone

subnet_id=$(aws ec2 create-subnet \
  --vpc-id $vpc_id \
  --cidr-block $cidr_block \
  --availability-zone $availability_zone \
  --output json | jq -r '.Subnet.SubnetId')

# Add a name tag to the subnet
aws ec2 create-tags --resources $subnet_id --tags Key=Name,Value=$subnet_name

echo "Subnet $subnet_name created with ID: $subnet_id"


# Create Internet Gateway ============================================
igw_id=$(aws ec2 create-internet-gateway --output json | jq -r '.InternetGateway.InternetGatewayId')

echo "Internet Gateway created with ID: $subnet_id"


# Attach Internet Gateway to VPC ========================================
aws ec2 attach-internet-gateway --vpc-id $vpc_id --internet-gateway-id $igw_id

echo "Attach Internet Gateway to VPC"


# Get the main route table ID associated with the VPC =====================
route_table_id=$(aws ec2 describe-route-tables --filters Name=vpc-id,Values=$vpc_id  --output json | jq -r '.RouteTables[].RouteTableId')

echo "Get the route table ID"


# Associate subnet with the route table (assumes you have a route table created) ========
aws ec2 associate-route-table --subnet-id $subnet_id --route-table-id $route_table_id

echo "Associate subnet with the route table "


# Create a route in the route table to the Internet Gateway
aws ec2 create-route --route-table-id $route_table_id --destination-cidr-block 0.0.0.0/0 --gateway-id $igw_id

echo "Create a route in the route table to the Internet Gateway"

# Create security group ==================================================
# Variables
security_group_name="kube"
description="kube security group description"

# Array of port numbers to open
ports=(80 443 22 3306)

# Create security group
security_group_id=$(aws ec2 create-security-group \
  --group-name "$security_group_name" \
  --description "$description" \
  --vpc-id "$vpc_id" \
  --output json | jq -r '.GroupId')

# Loop through the array and authorize ingress for each port
for port in "${ports[@]}"; do
  aws ec2 authorize-security-group-ingress \
    --group-id "$security_group_id" \
    --protocol tcp \
    --port "$port" \
    --cidr "0.0.0.0/0"
done

echo "Security group created with ID: $security_group_id"


# Create Key pair =======================================================
# Variables
key_pair_name="mykey"

# Generate a new key pair
aws ec2 create-key-pair --key-name $key_pair_name --query 'KeyMaterial' --output text > $key_pair_name.pem

# Secure the private key file
chmod 400 $key_pair_name.pem

echo "Key pair created with name: $key_pair_name. Private key saved to $key_pair_name.pem"


# Create EC2 ===========================================================
# Variables
ami_id="ami-0c7217cdde317cfec"  # Replace with your desired AMI ID
instance_type="t3.small"        # Replace with your desired instance type

# List of instance names
instance_names=("master" "Worker-1" "Worker-2" "Nginx") 

# Loop through the instances and launch them
for instance_name in "${instance_names[@]}"; do
  instance_id=$(aws ec2 run-instances \
    --image-id $ami_id \
    --instance-type $instance_type \
    --key-name $key_pair_name \
    --subnet-id $subnet_id \
    --security-group-ids $security_group_id \
    --associate-public-ip-address \
    --output json | jq -r '.Instances[0].InstanceId')

  # Add a name tag to the instance
  aws ec2 create-tags --resources $instance_id --tags Key=Name,Value=$instance_name

  echo "EC2 instance $instance_name created with ID: $instance_id"
done