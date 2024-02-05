# Makefile for creating a VPC, Private Subnet, Public Subnet, Internet Gateway, NAT Gateway, Route table, associating subnet with a route table, adding a route to the Internet Gateway,
# creating a security group, opening multiple ports, generating a new key pair, and creating multiple EC2 instances
# Delete also same resources

# all_resources delete_resources
# if can not delete any resources with "delete_resources" delete Manually.

# Variables
VPC_NAME=MyVPC
vpc_cidr_block="10.0.0.0/16"

SUBNET_NAME="MySubnetPublic"
subnet_cidr_block="10.0.1.0/24"
availability_zone="us-east-1a"  # replace with your desired availability zone


SUBNET_NAME_PRIVATE="MySubnetPrivate"
subnet_cidr_block_private="10.0.2.0/24"

IGW_NAME=MyIGW

NAT_GATEWAY_NAME=MyNat

ROUTE_TABLE_NAME=MyRouteTablePublic
ROUTE_TABLE_NAME_PRIVATE=MyRouteTablePrivate

SECURITY_GROUP_NAME = MySecurityGroupPublic
SECURITY_GROUP_DESCRIPTION = "My Security Group Description"
OPEN_PORTS = 22 80 5000

SECURITY_GROUP_NAME_PRIVATE = MySecurityGroupPrivate
OPEN_PORTS_PRIVATE = 2379-2380 6443 10250 22 27017 30001 30005
OPEN_PORTS_UDP = 8472 51820

KEY_PAIR_NAME = Key

PUBLIC_INSTANCE_NAMES =HostPC Nginx
PRIVATE_INSTANCE_NAMES =Master Worker-1 Worker-2

DELETE_INSTANCE_NAMES=$(PUBLIC_INSTANCE_NAMES) $(PRIVATE_INSTANCE_NAMES)


EC2_INSTANCE_TYPE = t2.small
AMI_ID = ami-0c7217cdde317cfec  # Replace with your desired AMI ID

all_resources: create_vpc create_subnet create_igw create_route_table associate_subnet_with_route_table create_route_to_igw create_subnet_private create_nat_gateway create_private_route_table associate_subnet_with_route_table_private create_route_to_nat_gateway create_security_group_with_ports_public create_security_group_with_ports_private create_key_pair create_private_ec2_instances create_public_ec2_instances

# Target to create a VPC
create_vpc:
	@echo "Creating VPC..."
	@vpc_id=$$(aws ec2 create-vpc --cidr-block $(vpc_cidr_block) --output json | jq -r '.Vpc.VpcId'); \
	aws ec2 create-tags --resources $$vpc_id --tags Key=Name,Value=$(VPC_NAME); \
	echo "VPC $(VPC_NAME) created with ID: $$vpc_id"

# Target to create a subnet
create_subnet:
	@echo "Creating Subnet..."
	@subnet_id=$$(aws ec2 create-subnet \
		--vpc-id $$(aws ec2 describe-vpcs --filter Name=tag:Name,Values=$(VPC_NAME) --query 'Vpcs[0].VpcId' --output json | jq -r '.') \
		--cidr-block $(subnet_cidr_block) \
		--availability-zone $(availability_zone) \
		--output json | jq -r '.Subnet.SubnetId'); \
	aws ec2 create-tags --resources $$subnet_id --tags Key=Name,Value=$(SUBNET_NAME); \
	echo "Subnet $(SUBNET_NAME) created with ID: $$subnet_id"


# Target to create an Internet Gateway and associate it with the VPC
create_igw:
	@echo "Creating Internet Gateway..."
	@igw_id=$$(aws ec2 create-internet-gateway --output json | jq -r '.InternetGateway.InternetGatewayId'); \
	aws ec2 create-tags --resources $$igw_id --tags Key=Name,Value=$(IGW_NAME); \
	aws ec2 attach-internet-gateway --internet-gateway-id $$igw_id --vpc-id $$(aws ec2 describe-vpcs --filter Name=tag:Name,Values=$(VPC_NAME) --query 'Vpcs[0].VpcId' --output json | jq -r '.'); \
	echo "Internet Gateway $(IGW_NAME) created and attached with ID: $$igw_id"

# Target to create a route table
create_route_table:
	@echo "Creating Route Table..."
	@route_table_id=$$(aws ec2 create-route-table --vpc-id $$(aws ec2 describe-vpcs --filter Name=tag:Name,Values=$(VPC_NAME) --query 'Vpcs[0].VpcId' --output json | jq -r '.') --output json | jq -r '.RouteTable.RouteTableId'); \
	aws ec2 create-tags --resources $$route_table_id --tags Key=Name,Value=$(ROUTE_TABLE_NAME); \
	echo "Route Table $(ROUTE_TABLE_NAME) created with ID: $$route_table_id"

# Target to associate subnet with route table
associate_subnet_with_route_table:
	@echo "Associating Subnet with Route Table..."
	@subnet_id=$$(aws ec2 describe-subnets --filter Name=tag:Name,Values=$(SUBNET_NAME) --query 'Subnets[0].SubnetId' --output json | jq -r '.'); \
	route_table_id=$$(aws ec2 describe-route-tables --filter Name=tag:Name,Values=$(ROUTE_TABLE_NAME) --query 'RouteTables[0].RouteTableId' --output json | jq -r '.'); \
	aws ec2 associate-route-table --subnet-id $$subnet_id --route-table-id $$route_table_id; \
	echo "Subnet $(SUBNET_NAME) associated with Route Table $(ROUTE_TABLE_NAME)"

# Target to create a route to the Internet Gateway in the route table
create_route_to_igw:
	@echo "Creating Route to Internet Gateway..."
	@route_table_id=$$(aws ec2 describe-route-tables --filter Name=tag:Name,Values=$(ROUTE_TABLE_NAME) --query 'RouteTables[0].RouteTableId' --output json | jq -r '.'); \
	igw_id=$$(aws ec2 describe-internet-gateways --filter Name=tag:Name,Values=$(IGW_NAME) --query 'InternetGateways[0].InternetGatewayId' --output json | jq -r '.'); \
	aws ec2 create-route --route-table-id $$route_table_id --destination-cidr-block 0.0.0.0/0 --gateway-id $$igw_id; \
	echo "Route to Internet Gateway added to Route Table $(ROUTE_TABLE_NAME)"


# Target to create a Private subnet
create_subnet_private:
	@echo "Creating Private Subnet..."
	@subnet_id=$$(aws ec2 create-subnet \
		--vpc-id $$(aws ec2 describe-vpcs --filter Name=tag:Name,Values=$(VPC_NAME) --query 'Vpcs[0].VpcId' --output json | jq -r '.') \
		--cidr-block $(subnet_cidr_block_private) \
		--availability-zone $(availability_zone) \
		--output json | jq -r '.Subnet.SubnetId'); \
	aws ec2 create-tags --resources $$subnet_id --tags Key=Name,Value=$(SUBNET_NAME_PRIVATE); \
	echo "Subnet $(SUBNET_NAME_PRIVATE) created with ID: $$subnet_id"

# Target to create a NAT Gateway
create_nat_gateway:
	@echo "Creating NAT Gateway..."
	@echo "Creating Elastic IP (EIP) Allocation..."
	@eip_allocation_id=$$(aws ec2 allocate-address --domain vpc --output json | jq -r '.AllocationId'); \
	subnet_id=$$(aws ec2 describe-subnets --filter Name=tag:Name,Values=$(SUBNET_NAME) --query 'Subnets[0].SubnetId' --output json | jq -r '.'); \
	nat_gateway_id=$$(aws ec2 create-nat-gateway --subnet-id $$subnet_id --allocation-id $$eip_allocation_id --output json | jq -r '.NatGateway.NatGatewayId'); \
	aws ec2 create-tags --resources $$nat_gateway_id --tags Key=Name,Value=$(NAT_GATEWAY_NAME); \
	echo "Sleeping for 120 seconds to ready NAT Gateway..."; \
	sleep 120; \
	echo "NAT Gateway $$nat_gateway_id created"


# Target to create a Private route table
create_private_route_table:
	@echo "Creating Private Route Table..."
	@route_table_id=$$(aws ec2 create-route-table --vpc-id $$(aws ec2 describe-vpcs --filter Name=tag:Name,Values=$(VPC_NAME) --query 'Vpcs[0].VpcId' --output json | jq -r '.') --output json | jq -r '.RouteTable.RouteTableId'); \
	aws ec2 create-tags --resources $$route_table_id --tags Key=Name,Value=$(ROUTE_TABLE_NAME_PRIVATE); \
	echo "Route Table $(ROUTE_TABLE_NAME_PRIVATE) created with ID: $$route_table_id"


# Target to associate Private subnet with Private route table
associate_subnet_with_route_table_private:
	@echo "Associating Private Subnet with Private Route Table..."
	@subnet_id=$$(aws ec2 describe-subnets --filter Name=tag:Name,Values=$(SUBNET_NAME_PRIVATE) --query 'Subnets[0].SubnetId' --output json | jq -r '.'); \
	route_table_id=$$(aws ec2 describe-route-tables --filter Name=tag:Name,Values=$(ROUTE_TABLE_NAME_PRIVATE) --query 'RouteTables[0].RouteTableId' --output json | jq -r '.'); \
	aws ec2 associate-route-table --subnet-id $$subnet_id --route-table-id $$route_table_id; \
	echo "Subnet $(SUBNET_NAME_PRIVATE) associated with Route Table $(ROUTE_TABLE_NAME_PRIVATE)"

# Target to create a route to the Nat Gateway in the route table
create_route_to_nat_gateway:
	@echo "Creating Route to Nat Gateway..."
	@route_table_id=$$(aws ec2 describe-route-tables --filter Name=tag:Name,Values=$(ROUTE_TABLE_NAME_PRIVATE) --query 'RouteTables[0].RouteTableId' --output json | jq -r '.'); \
	nat_gateway_id=$$(aws ec2 describe-nat-gateways --filter Name=tag:Name,Values=$(NAT_GATEWAY_NAME) --query 'NatGateways[0].NatGatewayId' --output json | jq -r '.'); \
	aws ec2 create-route --route-table-id $$route_table_id --destination-cidr-block 0.0.0.0/0 --gateway-id $$nat_gateway_id; \
	echo "Route to NAT Gateway added to Route Table $(ROUTE_TABLE_NAME_PRIVATE)"


# Target to create Public security group and open multiple ports
create_security_group_with_ports_public:
	@echo "Creating Public Security Group and Opening Ports..."
	@security_group_id=$$(aws ec2 create-security-group \
		--group-name $(SECURITY_GROUP_NAME) \
		--description $(SECURITY_GROUP_DESCRIPTION) \
		--vpc-id $$(aws ec2 describe-vpcs --filter Name=tag:Name,Values=$(VPC_NAME) --query 'Vpcs[0].VpcId' --output json | jq -r '.') \
		--output json | jq -r '.GroupId'); \
	for port in $(OPEN_PORTS); do \
		aws ec2 authorize-security-group-ingress --group-id $$security_group_id --protocol tcp --port $$port --cidr 0.0.0.0/0; \
	done; \
	echo "Security Group $(SECURITY_GROUP_NAME) created with ID: $$security_group_id and opened ports: $(OPEN_PORTS)"


# Target to create Private security group and open multiple ports
create_security_group_with_ports_private:
	@echo "Creating Private Security Group and Opening Ports..."
	@security_group_id=$$(aws ec2 create-security-group \
		--group-name $(SECURITY_GROUP_NAME_PRIVATE) \
		--description $(SECURITY_GROUP_DESCRIPTION) \
		--vpc-id $$(aws ec2 describe-vpcs --filter Name=tag:Name,Values=$(VPC_NAME) --query 'Vpcs[0].VpcId' --output json | jq -r '.') \
		--output json | jq -r '.GroupId'); \
	for port in $(OPEN_PORTS_PRIVATE); do \
		aws ec2 authorize-security-group-ingress --group-id $$security_group_id --protocol tcp --port $$port --cidr 0.0.0.0/0; \
	done; \
	for port_udp in $(OPEN_PORTS_UDP); do \
		aws ec2 authorize-security-group-ingress --group-id $$security_group_id --protocol udp --port $$port_udp --cidr 0.0.0.0/0; \
	done; \
	echo "Security Group $(SECURITY_GROUP_NAME_PRIVATE) created with ID: $$security_group_id and opened ports: $(OPEN_PORTS_PRIVATE) $(OPEN_PORTS_UDP)"

# Target to generate a new key pair
create_key_pair:
	@echo "Generating Key Pair..."
	@aws ec2 create-key-pair --key-name $(KEY_PAIR_NAME) --output json | jq -r '.KeyMaterial' > $(KEY_PAIR_NAME).pem; \
	echo "Key Pair $(KEY_PAIR_NAME) generated and saved as $(KEY_PAIR_NAME).pem"


# Target to create public EC2 instances
create_public_ec2_instances:
	@echo "Creating public EC2 Instances..."
	@subnet_id=$$(aws ec2 describe-subnets --filter Name=tag:Name,Values=$(SUBNET_NAME) --query 'Subnets[0].SubnetId' --output json | jq -r '.'); \
	security_group_id=$$(aws ec2 describe-security-groups --filter Name=group-name,Values=$(SECURITY_GROUP_NAME) --query 'SecurityGroups[0].GroupId' --output json | jq -r '.'); \
	key_pair_name=$(KEY_PAIR_NAME); \
	instance_count=0; \
	for public_instance_name in  $(PUBLIC_INSTANCE_NAMES); do \
		aws ec2 run-instances \
			--image-id $(AMI_ID) \
			--instance-type $(EC2_INSTANCE_TYPE) \
			--key-name $$key_pair_name \
			--subnet-id $$subnet_id \
			--security-group-ids $$security_group_id \
			--associate-public-ip-address \
			--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value='$$public_instance_name'}]' \
			--count 1; \
		instance_count=$$((instance_count + 1)); \
	done; \
	echo "EC2 Instances created in Subnet $(SUBNET_NAME) with names: $(PUBLIC_INSTANCE_NAMES)"



# Target to create Private EC2 instances
create_private_ec2_instances:
	@echo "Creating Private EC2 Instances..."
	@subnet_id=$$(aws ec2 describe-subnets --filter Name=tag:Name,Values=$(SUBNET_NAME_PRIVATE) --query 'Subnets[0].SubnetId' --output json | jq -r '.'); \
	security_group_id=$$(aws ec2 describe-security-groups --filter Name=group-name,Values=$(SECURITY_GROUP_NAME_PRIVATE) --query 'SecurityGroups[0].GroupId' --output json | jq -r '.'); \
	key_pair_name=$(KEY_PAIR_NAME); \
	instance_count=0; \
	for private_instance_name in  $(PRIVATE_INSTANCE_NAMES); do \
		aws ec2 run-instances \
			--image-id $(AMI_ID) \
			--instance-type $(EC2_INSTANCE_TYPE) \
			--key-name $$key_pair_name \
			--subnet-id $$subnet_id \
			--security-group-ids $$security_group_id \
			--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value='$$private_instance_name'}]' \
			--count 1; \
		instance_count=$$((instance_count + 1)); \
	done; \
	echo "EC2 Instances created in Subnet $(SUBNET_NAME_PRIVATE) with names: $(PRIVATE_INSTANCE_NAMES)"


delete_resources: delete_ec2 delete_key_pair delete_security_group delete_Nat delete_eip delete_igw delete_route_table delete_subnet  delete_vpc

# Target to delete a delete EC2
delete_ec2:
	@echo "Cleaning up resources..."
	@echo "Deleting Private & Public EC2 Instances..."
	@for instance_name in $(DELETE_INSTANCE_NAMES); do \
		instance_id=$$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$$instance_name" --query 'Reservations[*].Instances[?State.Name==`running`].InstanceId' --output json | jq -r '.[][]'); \
		if [ ! -z "$$instance_id" ]; then \
			aws ec2 terminate-instances --instance-ids $$instance_id; \
			echo "EC2 Instance $$instance_name terminated"; \
		else \
			echo "EC2 Instance $$instance_name not found"; \
		fi; \
	done
	
# Target to delete a delete key pair
delete_key_pair:
	@echo "Deleting Key Pair..."
	@aws ec2 delete-key-pair --key-name $(KEY_PAIR_NAME)
	echo "Key Pair $(KEY_PAIR_NAME) deleted"

# Target to delete a security group
delete_security_group:
	@echo "Deleting Security Group..."
	@echo "Sleeping for 60 seconds to stop Instance..."
	@sleep 60
	@security_group_id=$$(aws ec2 describe-security-groups --filters "Name=group-name,Values=$(SECURITY_GROUP_NAME)" --query 'SecurityGroups[0].GroupId' --output json | jq -r '.'); \
	aws ec2 delete-security-group --group-id $$security_group_id; \
	security_group_id_private=$$(aws ec2 describe-security-groups --filters "Name=group-name,Values=$(SECURITY_GROUP_NAME_PRIVATE)" --query 'SecurityGroups[0].GroupId' --output json | jq -r '.'); \
	aws ec2 delete-security-group --group-id $$security_group_id_private; \
	echo "Security Group $$security_group_id  $$security_group_id_private deleted"


# Target to delete an Nat Gateway
delete_Nat:
	@echo "Deleting Nat Gateway..."
	@nat_gateway_id=$$(aws ec2 describe-nat-gateways --filter "Name=tag:Name,Values=$(NAT_GATEWAY_NAME)" --query 'NatGateways[?State==`available`].NatGatewayId' --output json | jq -r '.[0]'); \
	aws ec2 delete-nat-gateway --nat-gateway-id $$nat_gateway_id ; \
	echo "Sleeping for 60 seconds to Delete Nat Gateway..."; \
	sleep 60 ; \
	echo "Nat Gateway $$nat_gateway_id deleted"	

# Target to Releas Elastic IP
delete_eip:
	@echo "Releasing Elastic IP address..."
	@elastic_ip_id=$$(aws ec2 describe-addresses --query 'Addresses[0].AllocationId' --output json | jq -r '.'); \
	aws ec2 release-address --allocation-id $$elastic_ip_id; \
	echo "Elastic IP $$elastic_ip_id deleted"	

# Target to delete an Internet Gateway
delete_igw:
	@echo "Deleting Internet Gateway..."
	@igw_id=$$(aws ec2 describe-internet-gateways --filters Name=tag:Name,Values=$(IGW_NAME) --query 'InternetGateways[0].InternetGatewayId' --output json | jq -r '.'); \
	aws ec2 detach-internet-gateway --internet-gateway-id $$igw_id --vpc-id $(shell aws ec2 describe-internet-gateways --internet-gateway-id $$igw_id --query 'InternetGateways[0].Attachments[0].VpcId' --output json | jq -r '.'); \
	aws ec2 delete-internet-gateway --internet-gateway-id $$igw_id; \
	echo "Sleeping for 60 seconds to Delete Internet Gateway..."; \
	sleep 60 ; \
	echo "Internet Gateway $$igw_id deleted"

# Target to delete a Route Table
delete_route_table:
	@echo "Deleting Route Table..."
	@route_table_id=$$(aws ec2 describe-route-tables --filters "Name=tag:Name,Values=$(ROUTE_TABLE_NAME)" --query 'RouteTables[0].RouteTableId' --output json | jq -r '.'); \
	aws ec2 delete-route-table --route-table-id $$route_table_id; \
	echo "Route Table $$route_table_id deleted"; \
	route_table_id_private=$$(aws ec2 describe-route-tables --filters "Name=tag:Name,Values=$(ROUTE_TABLE_NAME_PRIVATE)" --query 'RouteTables[0].RouteTableId' --output json | jq -r '.'); \
	aws ec2 delete-route-table --route-table-id $$route_table_id_private; \
	echo "Route Table  $$route_table_id_private deleted"

# Target to delete a subnet
delete_subnet:
	@echo "Deleting Subnet..."
	@subnet_id=$$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=$(SUBNET_NAME)" --query 'Subnets[0].SubnetId' --output json | jq -r '.'); \
	aws ec2 delete-subnet --subnet-id $$subnet_id; \
	subnet_id_private=$$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=$(SUBNET_NAME_PRIVATE)" --query 'Subnets[0].SubnetId' --output json | jq -r '.'); \
	aws ec2 delete-subnet --subnet-id $$subnet_id_private; \
	echo "Subnet $$subnet_id, $$subnet_id_private deleted"

# Target to delete a VPC
delete_vpc:
	@echo "Deleting VPC..."
	@vpc_id=$$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=$(VPC_NAME)" --query 'Vpcs[0].VpcId' --output json | jq -r '.'); \
	aws ec2 delete-vpc --vpc-id $$vpc_id; \
	echo "VPC $$vpc_id deleted"