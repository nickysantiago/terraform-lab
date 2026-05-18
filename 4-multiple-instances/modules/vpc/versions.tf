# ============================================================
# MODULE: vpc - Provider Requirements
# Specifies minimum Terraform and provider versions.
# NOTE: No provider block here. Provider configuration
# is always done in the calling environment, not the module.
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
