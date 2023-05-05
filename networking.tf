#VPC
resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "myvpc"
  }
}

#Public Subnet1
resource "aws_subnet" "public_subnet1" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "public_subnet1"
  }
}

#Public Subnet2
resource "aws_subnet" "public_subnet2" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "public_subnet2"
  }
}

#Private Subnet1
resource "aws_subnet" "private_subnet1" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private_subnet1"
  }
}

#Private Subnet2
resource "aws_subnet" "private_subnet2" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "private_subnet2"
  }
}

#Internet Gateway
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.myvpc.id

    tags = {
      Name = "igw"
    }
}

#Route table
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.myvpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw
    }

    tags = {
      Name = "public"
    }
}

#Route table association public_subnet1
resource "aws_route_table_association" "public_subnet1" {
    subnet_id = aws_subnet.public_subnet1.id
    route_table_id = aws_route_table.public.id  
}

#Route table association public_subnet2
resource "aws_route_table_association" "public_subnet2" {
    subnet_id = aws_subnet.public_subnet2.id
    route_table_id = aws_route_table.public.id  
}