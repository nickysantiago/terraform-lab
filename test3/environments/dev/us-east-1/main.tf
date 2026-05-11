# ============================================================
# ENVIRONMENT: dev / us-east-1
#
# This is the entry point for the dev environment.
# It calls the vpc and ec2 modules with dev-specific parameters.
# Notice: no resource blocks here - only module calls.
# All actual resources are defined inside the modules.
# ============================================================

# ---- VPC Module ----
# Creates all networking: VPC, subnet, IGW, route table
module "vpc" {
  source = "../../../modules/vpc"

  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  availability_zone  = var.availability_zone

  tags = local.common_tags
}

# ---- EC2 Module ----
# Creates security group and EC2 instance.
# Notice how vpc_id and subnet_id come from the vpc module outputs.
# This is the dependency chain in action - ec2 cannot run
# until vpc has completed and produced its outputs.
module "ec2" {
  source = "../../../modules/ec2"

  environment   = var.environment
  instance_name = var.instance_name
  instance_type = var.instance_type
  key_pair_name = var.key_pair_name

  # These values flow from the vpc module outputs into ec2 inputs.
  # Terraform automatically understands this creates a dependency:
  # vpc module must complete before ec2 module begins.
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.public_subnet_id

  tags = local.common_tags
}

# ---- Local Values ----
# Shared values computed once and reused across module calls.
locals {
  common_tags = {
    Environment = var.environment
    Region      = var.aws_region
    ManagedBy   = "terraform"
    Project     = "terraform-test"
  }
}
