resource "aws_instance" "public" {
  ami                         = "ami-679593333241"
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  key_name                    = "main"
  vpc_security_group_ids      = [aws_security_group.public.id]
  subnet_id                   = aws_subnet.public[0].id

  tags = {
    Name = "${var.env}-public"
  }
}

resource "aws_security_group" "public" {
  name              = "${var.env}-public"
  descridescription = "Allow inbound terrafic"
  vpc_id            = aws_vpc.vpc.id

  ingress {
    description = "SSH from public"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["37.22.15.14/32"]
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