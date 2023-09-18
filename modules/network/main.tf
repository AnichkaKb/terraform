###########
# AWS-VPC #
###########

resource "aws_vpc" "module_vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name="vpc-env"
  }
}

##############
# AWS-SUBNET #
##############

resource "aws_subnet" "module_subnet" {
  vpc_id     = aws_vpc.module_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "PrivateDbSubnet" {
  vpc_id            = aws_vpc.module_vpc.id
  availability_zone =  "us-east-1a"
  cidr_block        = "10.0.2.0/24"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "PrivateAppSubnet" {
  vpc_id            = aws_vpc.module_vpc.id
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.3.0/24"
  map_public_ip_on_launch = false
}
resource "aws_subnet" "PrivateAppSubnet2" {
  vpc_id            = aws_vpc.module_vpc.id
  availability_zone = "us-east-1b"
  cidr_block        = "10.0.4.0/24"
  map_public_ip_on_launch = false
}

########################
# AWS-INTERNET-GATEWAY #
########################

resource "aws_internet_gateway" "test-env-gw" {
  vpc_id = aws_vpc.module_vpc.id
tags = {
    Name = "internet-gateway"
  }
}

###################
# AWS ROUTE TABLE #
###################

resource "aws_route_table" "route-table-test-env" {
  vpc_id = aws_vpc.module_vpc.id
route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test-env-gw.id
  }
tags = {
    Name = "route-table"
  }
}
###############################
# AWS ROUTE TABLE ASSOCIATION #
###############################

resource "aws_route_table_association" "subnet-association" {
  subnet_id      = aws_subnet.module_subnet.id
  route_table_id = aws_route_table.route-table-test-env.id
}

