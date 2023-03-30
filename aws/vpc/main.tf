provider "aws" {
  region = "eu-west-2"
}

# create a VPC
resource "aws_vpc" "brivantech" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "brivantechvpc"
  }
}

# create an internet gateway
resource "aws_internet_gateway" "brivantech" {
  vpc_id = aws_vpc.brivantech.id
  tags = {
    Name = "brivantech-igw"
  }
}

# create a public subnet
resource "aws_subnet" "public" {
  vpc_id = aws_vpc.brivantech.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-west-2"
  tags = {
    Name = "brivantech-public-subnet"
  }
}

# associate the public subnet with the internet gateway
resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_vpc.brivantech.main_route_table_id
}

# create a private subnet
resource "aws_subnet" "private" {
  vpc_id = aws_vpc.brivantech.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-2b"
  tags = {
    Name = "brivantech-private-subnet"
  }
}

# create a route table for the private subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.brivantech.id
  tags = {
    Name = "brivantech-private-route-table"
  }
}

# associate the private subnet with the private route table
resource "aws_route_table_association" "private" {
  subnet_id = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# create a NAT gateway for the private subnet
resource "aws_nat_gateway" "brivantech" {
  allocation_id = aws_eip.nat.id
  subnet_id = aws_subnet.public.id
}

# create an EIP for the NAT gateway
resource "aws_eip" "nat" {
  vpc = true
}

# create a default route in the private route table to use the NAT gateway
resource "aws_route" "private" {
  route_table_id = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.brivantech.id
}