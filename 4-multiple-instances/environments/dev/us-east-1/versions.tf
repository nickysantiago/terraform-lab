# ============================================================
# ENVIRONMENT: dev / us-east-1 - Provider Configuration
#
# Unlike modules (which only declare required_providers),
# environments configure the actual provider with region,
# credentials, and default tags.
# ============================================================

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  # Default tags applied to every resource in this environment.
  # No need to repeat these in every resource or module call.
  default_tags {
    tags = {
      Environment = "dev"
      ManagedBy   = "terraform"
      Region      = "us-east-1"
    }
  }
}
