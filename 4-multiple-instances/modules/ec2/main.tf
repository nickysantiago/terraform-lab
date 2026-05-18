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
