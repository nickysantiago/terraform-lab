# ============================================================
# TERRAFORM CONFIGURATION
# Launches an EC2 instance with full networking stack.
# No AWS default resources used - everything is explicit.
# ============================================================

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ============================================================
# PROVIDER
# ============================================================

provider "aws" {
  region = var.aws_region
}

# ============================================================
# VARIABLES
# ============================================================

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "my-terraform-instance-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Availability zone for the subnet"
  type        = string
  default     = "us-east-1a"
}

variable "key_pair_name" {
  description = "Name of an existing EC2 key pair for SSH access. Leave empty to skip."
  type        = string
  default     = ""
}

# ============================================================
# DATA SOURCES
# ============================================================

# Look up the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ============================================================
# NETWORKING
# ============================================================

# --- VPC ---
# The top-level network container. Everything lives inside this.
# Without this, we'd be relying on the AWS default VPC.
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  # These two settings allow EC2 instances to get public DNS names
  # and resolve AWS service hostnames inside the VPC
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name      = "terraform-test-vpc"
    ManagedBy = "terraform"
  }
}

# --- Internet Gateway ---
# Acts as the door between the VPC and the public internet.
# Without this, nothing inside the VPC can reach the internet
# and nothing from the internet can reach instances inside.
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name      = "terraform-test-igw"
    ManagedBy = "terraform"
  }
}

# --- Public Subnet ---
# A slice of the VPC's IP range in a specific availability zone.
# "Public" means instances here can get a public IP and reach
# the internet via the internet gateway.
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidr
  availability_zone = var.availability_zone

  # Automatically assign a public IP to instances launched here
  map_public_ip_on_launch = true

  tags = {
    Name      = "terraform-test-public-subnet"
    ManagedBy = "terraform"
  }
}

# --- Route Table ---
# A set of rules that determines where network traffic is directed.
# Without a route to the internet gateway, traffic from the
# subnet has nowhere to go outside the VPC.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  # This route sends all traffic (0.0.0.0/0 means "everything")
  # to the internet gateway. This is what makes the subnet "public".
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name      = "terraform-test-public-rt"
    ManagedBy = "terraform"
  }
}

# --- Route Table Association ---
# Links the route table to the subnet.
# A route table is useless until it's associated with a subnet.
# Without this, the subnet uses the VPC's default route table
# which has no internet route.
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ============================================================
# SECURITY GROUP
# ============================================================

# Acts as a virtual firewall for the EC2 instance.
# Explicitly attached to our VPC - not the default VPC.
resource "aws_security_group" "instance_sg" {
  name        = "terraform-test-sg"
  description = "Security group for terraform test instance"
  vpc_id      = aws_vpc.main.id

  # Allow inbound SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = {
    Name      = "terraform-test-sg"
    ManagedBy = "terraform"
  }
}

# ============================================================
# EC2 INSTANCE
# ============================================================

resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  # Place the instance in our explicit subnet - not a default subnet
  subnet_id = aws_subnet.public.id

  # Attach our security group
  vpc_security_group_ids = [aws_security_group.instance_sg.id]

  # Attach key pair only if one was provided
  key_name = var.key_pair_name != "" ? var.key_pair_name : null

  tags = {
    Name      = var.instance_name
    ManagedBy = "terraform"
  }
}

# ============================================================
# OUTPUTS
# ============================================================

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.web.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.web.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.web.public_dns
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

