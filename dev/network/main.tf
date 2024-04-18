module "vpc" {
  source              = "../../modules/aws_network"
  default_tags        = var.default_tags
  vpc_cidr            = var.vpc_cidr
  public_cidr_blocks  = var.public_subnet_cidrs
  private_cidr_blocks = var.private_subnet_cidrs
  prefix              = var.prefix
}
