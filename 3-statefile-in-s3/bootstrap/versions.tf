# ============================================================
# BOOTSTRAP: versions.tf
#
# Provider configuration for the bootstrap.
# Notice there is NO backend block here - this is intentional.
# Bootstrap always uses local state.
# ============================================================

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # NO backend block here.
  # Bootstrap stores its state locally.
  # That local terraform.tfstate file should be kept safe
  # and optionally committed to Git since it contains no
  # sensitive values - only S3 and DynamoDB resource IDs.
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      ManagedBy = "terraform-bootstrap"
    }
  }
}
