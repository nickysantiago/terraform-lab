# ============================================================
# ENVIRONMENT: dev / us-east-1 - Variable Values
#
# This is where actual values live.
# Everything in variables.tf is DECLARED here.
#
# This file IS safe to commit to Git for non-sensitive values.
# Never put passwords, API keys, or secrets in this file.
# ============================================================

# Region and environment
aws_region  = "us-east-1"
environment = "dev"

# Networking
# Using 10.0.0.0/16 for dev. Prod uses 10.2.0.0/16.
# Keep CIDRs unique per environment to allow VPC peering later.
vpc_cidr           = "10.0.0.0/16"
public_subnet_cidr = "10.0.1.0/24"
availability_zone  = "us-east-1a"

# EC2 Instance
# Small and cheap for dev - scale up in prod
instance_type = "t2.micro"
instance_name = "my-terraform-instance-1"
instance_name_2 = "my-terraform-instance-2"
instance_name_3 = "my-terraform-instance-3"

# SSH key pair name (must already exist in AWS)
# Leave as empty string if you don't need SSH access
key_pair_name = ""
