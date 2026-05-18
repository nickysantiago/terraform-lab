# ============================================================
# ENVIRONMENT: dev / us-east-1 - Outputs
#
# Surfaces useful values after terraform apply completes.
# These are printed to the terminal and accessible via
# terraform output <name>
# ============================================================

# ---- VPC Outputs ----
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = module.vpc.public_subnet_id
}

# ---- EC2 Outputs ----
output "instance_id" {
  description = "EC2 instance ID"
  value       = module.ec2.instance_id
}

output "instance_public_ip" {
  description = "Public IP - use this to SSH in"
  value       = module.ec2.instance_public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the instance"
  value       = module.ec2.instance_public_dns
}

output "instance_private_ip" {
  description = "Private IP address of the instance"
  value       = module.ec2.instance_private_ip
}

# 2nd EC2 instance
output "instance_2_id" {
  description = "EC2 instance 2 ID"
  value       = module.ec2_2nd.instance_id
}

output "instance_2_public_ip" {
  description = "Public IP of instance 2"
  value       = module.ec2_2nd.instance_public_ip
}

output "instance_2_public_dns" {
  description = "Public DNS name of instance 2"
  value       = module.ec2_2nd.instance_public_dns
}

output "instance_2_private_ip" {
  description = "Private IP address of instance 2"
  value       = module.ec2_2nd.instance_private_ip
}

# 3rd EC2 instance
output "instance_3_id" {
  description = "EC2 instance 2 ID"
  value       = module.ec2_3rd.instance_id
}

output "instance_3_public_ip" {
  description = "Public IP of instance 2"
  value       = module.ec2_3rd.instance_public_ip
}

output "instance_3_public_dns" {
  description = "Public DNS name of instance 2"
  value       = module.ec2_3rd.instance_public_dns
}

output "instance_3_private_ip" {
  description = "Private IP address of instance 2"
  value       = module.ec2_3rd.instance_private_ip
}

# ---- Convenience Output ----
output "ssh_command" {
  description = "SSH command to connect to the instance (if key pair was provided)"
  value       = var.key_pair_name != "" ? "ssh -i ~/.ssh/${var.key_pair_name}.pem ec2-user@${module.ec2.instance_public_ip}" : "No key pair configured"
}
