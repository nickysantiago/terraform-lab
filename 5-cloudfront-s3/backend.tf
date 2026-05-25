# ============================================================
# ENVIRONMENT: dev / us-east-1 - Backend Configuration
#
# Configures where Terraform stores its state file.
# Without this block, state is stored locally (terraform.tfstate).
#
# TO USE THIS:
#   1. Create the S3 bucket and DynamoDB table first (bootstrap)
#   2. Replace the placeholder values below with real ones
#   3. Run: terraform init
#      Terraform will migrate local state to S3 automatically
#
# TO KEEP USING LOCAL STATE FOR NOW:
#   Leave this file as-is with the block commented out.
#   Your state will remain in terraform.tfstate locally.
# ============================================================

 terraform {
   backend "s3" {
     bucket         = "terraform-state-259563981482"
     key            = "5/dev/us-east-1/terraform.tfstate"
     region         = "us-east-1"
     encrypt        = true
     use_lockfile   = true
   }
 }