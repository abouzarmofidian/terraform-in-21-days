#local
locals {
  public_cidr       = ["10.0.0.0/24", "10.0.1.0/24"]
  private_cidr      = ["10.0.2.0/24", "10.0.3.0/24"]
  availability_zone = ["us-east-1a", "us-east-1b"]
}

#VPC
resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "myvpc"
  }
}

#Public Subnet
resource "aws_subnet" "public" {
  count             = length(local.public_cidr)
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = local.public_cidr[count.index]
  availability_zone = local.availability_zone[count.index]

  tags = {
    Name = "public${count.index + 1}"
  }
}

#Private Subnet
resource "aws_subnet" "private" {
  count             = length(local.private_cidr)
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = local.private_cidr[count.index]
  availability_zone = local.availability_zone[count.index]

  tags = {
    Name = "private${count.index + 1}"
  }
}

#Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "igw"
  }
}

#Route table for public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public"
  }
}

#Route table association public_subnet
resource "aws_route_table_association" "public" {
  count          = length(local.public_cidr)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

#eip
resource "aws_eip" "nat" {
  count = length(local.public_cidr)

  vpc = true
  tags = {
    Name = "nat${count.index + 1}"
  }
}

#NAT Gateway
resource "aws_nat_gateway" "natgw" {
  count = length(local.public_cidr)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "natgw${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.igw]
}

# Route table for private subnet 
resource "aws_route_table" "private" {
  count  = length(local.private_cidr)
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw[count.index].id
  }

  tags = {
    Name = "private${count.index + 1}"
  }
}


#Route table association private_subne
resource "aws_route_table_association" "private" {
  count          = length(local.private_cidr)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}