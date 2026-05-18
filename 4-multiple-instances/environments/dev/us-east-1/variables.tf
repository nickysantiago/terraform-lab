# ============================================================
# ENVIRONMENT: dev / us-east-1 - Variables
#
# Declares all variables this environment accepts.
# Actual values come from terraform.tfvars.
# ============================================================

variable "aws_region" {
  description = "AWS region for this environment"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone for the subnet"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
}

variable "instance_name_2" {
  description = "Name tag for the 2nd EC2 instance"
  type        = string
}

variable "instance_name_3" {
  description = "Name tag for the 3rd EC2 instance"
  type        = string
}

variable "key_pair_name" {
  description = "Existing EC2 key pair name for SSH. Leave empty to skip."
  type        = string
  default     = ""
}
