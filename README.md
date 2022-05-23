# VPC with DMZ public zone

## Description
The module creates a VPC with a public and private subnet in each Availability Zone.
The private subnet cannot be accessed from the public subnet

## Usage
```hcl
module "dmz-vpc" {
  source = ""
  stack_name = "sftp"
}
```

### Parameters

##### stack_name (Required)
Name to prepend to all named resources, and for tagging

##### vpc_cidr_head
The head of the VPC CIDR range. The VPC will be created as /16 network

##### number_of_az
The number of Availability zones the VPC will span. Each AZ will contain one public DMZ and one private subnet<br>
The subnet will be created as /24 network with CIDR range calculated from *vpc_cidr_head* 

## Resources
* VPC
* Public Subnet(s). DMZ
* Private subnet(s)
* Security groups to access Public subnet(s) from VPC

### Additional resources
For demonstration purposes, the module also creates a EC2 instance in each subnet


