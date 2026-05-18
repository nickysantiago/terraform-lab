# ============================================================
# MODULE: ec2 - Input Variables
# ============================================================

variable "environment" {
  description = "Environment name used for tagging and naming resources (e.g. dev, staging, prod)"
  type        = string
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type (e.g. t2.micro, t3.medium)"
  type        = string
  default     = "t2.micro"
}

# These two variables come from the VPC module outputs.
# The ec2 module has no knowledge of how the VPC was created -
# it just needs the IDs to place resources in the right location.

variable "vpc_id" {
  description = "ID of the VPC to place the security group in. Use module.vpc.vpc_id"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet to launch the instance in. Use module.vpc.public_subnet_id"
  type        = string
}

variable "key_pair_name" {
  description = "Name of an existing EC2 key pair for SSH access. Leave empty to skip."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags to apply to all resources in this module"
  type        = map(string)
  default     = {}
}
