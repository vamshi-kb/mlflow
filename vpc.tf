module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"

  name               = "${var.name}-vpc"
  cidr               = "10.0.0.0/16"
  create_vpc         = false
  azs                = var.vpc-availability_zone_names
  private_subnets    = var.db_subnet_ids
  enable_nat_gateway = true

}