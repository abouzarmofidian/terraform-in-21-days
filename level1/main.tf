# Declare the data source
data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "../modules/vpc"

  env = "orlando"
  vpc_cidr = "10.0.0.0/16"
  public_cidr = ["10.1.0.0/24", "10.2.0.0/24"]
  private_cidr = ["10.3.0.0/24", "10.4.0.0/24"]
  availability_zone = data.aws_availability_zones.available.names

}