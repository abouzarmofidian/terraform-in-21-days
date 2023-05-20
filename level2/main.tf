data "aws_ami" "amazonlinux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

#Public instance
resource "aws_instance" "public" {
  count = 2

  ami                         = data.aws_ami.amazonlinux.id
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  key_name                    = "main"
  vpc_security_group_ids      = [aws_security_group.public.id]
  subnet_id                   = data.terraform_remote_state.level1.outputs.public_subnet_id[count.index]


  tags = {
    Name = "${var.env}-public"
  }
}

resource "aws_security_group" "public" {
  name              = "${var.env}-public"
  descridescription = "Allow inbound terrafic"
  vpc_id            = data.terraform_remote_state.level1.outputs.vpc_id

  ingress {
    description = "SSH from public"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["37.22.15.14/32"]
  }

  ingress {
    description     = "HTTP from public"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer.id]
  }

  ingress {
    description = "HTTP from load balancer"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-public"
  }
}

#Private instance
resource "aws_instance" "private" {
  count = 2

  ami                    = data.aws_ami.amazonlinux.id
  instance_type          = "t2.micro"
  key_name               = "main"
  vpc_security_group_ids = [aws_security_group.private.id]
  subnet_id              = data.terraform_remote_state.level1.outputs.private_subnet_id[count.index]
  user_data              = file("user-data.sh")

  tags = {
    Name = "${var.env}-private"
  }
}


resource "aws_security_group" "private" {
  name              = "${var.env}-private"
  descridescription = "Allow VPC terrafic"
  vpc_id            = data.terraform_remote_state.level1.outputs.vpc_id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.level1.outputs.vpc_cidr]
  }

  ingress {
    description     = "HTTP from load balancer"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-private"
  }
}