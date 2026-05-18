# ============================================================
# MODULE: ec2
# Creates a security group and EC2 instance.
# Requires a vpc_id and subnet_id from the vpc module.
# ============================================================

# Look up the latest Amazon Linux 2023 AMI.
# Data sources are fine in modules - they are read-only
# and don't create anything.
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

# Security Group
# Attached to the VPC passed in via variable.
# This is why vpc_id must be an input - the security group
# must live in the same VPC as the instance.
resource "aws_security_group" "instance" {
  name        = "${var.environment}-${var.instance_name}-sg"
  description = "Security group for ${var.instance_name}"
  vpc_id      = var.vpc_id

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
    Name = "${var.environment}-${var.instance_name}-sg"
  })
}

# EC2 Instance
# Placed in the subnet passed in via variable.
# The subnet determines the AZ and whether it gets a public IP.
resource "aws_instance" "this" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  vpc_security_group_ids = [aws_security_group.instance.id]

  key_name = var.key_pair_name != "" ? var.key_pair_name : null

  tags = merge(var.tags, {
    Name = var.instance_name
  })
}
