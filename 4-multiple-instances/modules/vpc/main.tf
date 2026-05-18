# ============================================================
# MODULE: vpc
# Creates a VPC with one public subnet, internet gateway,
# and route table. Self-contained - no external dependencies.
# ============================================================

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name = "${var.environment}-vpc"
  })
}

# Internet Gateway
# Connects the VPC to the public internet.
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.environment}-igw"
  })
}

# Public Subnet
# Instances launched here receive a public IP automatically.
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.environment}-public-subnet"
    Type = "public"
  })
}

# Route Table
# The default route (0.0.0.0/0) points to the internet gateway,
# making this a public route table.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-public-rt"
  })
}

# Route Table Association
# Without this the subnet uses the VPC's default route table
# which has no internet route.
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Shared Security Group
# Lives in the VPC module because it's a network-level resource.
# All EC2 instances in this VPC use this single security group.
resource "aws_security_group" "instances" {
  name        = "${var.environment}-instances-sg"
  description = "Shared security group for all instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-instances-sg"
  })
}
