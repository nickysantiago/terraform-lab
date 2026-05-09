# ============================================================
# MODULE: vpc - Input Variables
# These are the parameters callers must (or can) pass in.
# ============================================================

variable "environment" {
  description = "Environment name used for tagging and naming resources (e.g. dev, staging, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC (e.g. 10.0.0.0/16)"
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid CIDR block."
  }
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet. Must be within the VPC CIDR (e.g. 10.0.1.0/24)"
  type        = string

  validation {
    condition     = can(cidrhost(var.public_subnet_cidr, 0))
    error_message = "public_subnet_cidr must be a valid CIDR block."
  }
}

variable "availability_zone" {
  description = "Availability zone to launch the subnet in (e.g. us-east-1a)"
  type        = string
}

variable "tags" {
  description = "Additional tags to apply to all resources in this module"
  type        = map(string)
  default     = {}
}
