#VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${var.env}-vpc"
  }
}

#Public Subnet
resource "aws_subnet" "public" {
  count             = length(var.public_cidr)
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = var.public_cidr[count.index]
  availability_zone = var.availability_zone[count.index]

  tags = {
    Name = "${var.env}-public${count.index + 1}"
  }
}

#Private Subnet
resource "aws_subnet" "private" {
  count             = length(var.private_cidr)
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = var.private_cidr[count.index]
  availability_zone = var.availability_zone[count.index]

  tags = {
    Name = "${var.env}-private${count.index + 1}"
  }
}

#Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "${var.env}-gw"
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
    Name = "${var.env}-public"
  }
}

#Route table association public_subnet
resource "aws_route_table_association" "public" {
  count          = length(var.public_cidr)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

#eip
resource "aws_eip" "nat" {
  count = length(var.public_cidr)
  vpc = true
  tags = {
    Name = "${var.env}-nat${count.index + 1}"
  }
}

#NAT Gateway
resource "aws_nat_gateway" "natgw" {
  count = length(var.public_cidr)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.env}-natgw${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.igw]
}

# Route table for private subnet 
resource "aws_route_table" "private" {
  count  = length(var.private_cidr)
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw[count.index].id
  }

  tags = {
    Name = "${var.env}-private${count.index + 1}"
  }
}


#Route table association private_subne
resource "aws_route_table_association" "private" {
  count          = length(var.private_cidr)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}