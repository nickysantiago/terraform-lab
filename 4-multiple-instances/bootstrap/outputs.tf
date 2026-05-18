# ============================================================
# BOOTSTRAP: outputs.tf
#
# Prints the bucket name and table name after apply completes.
# Copy these values directly into backend.tf for each environment.
# ============================================================

output "state_bucket_name" {
  description = "S3 bucket name - use as 'bucket' in backend.tf"
  value       = aws_s3_bucket.terraform_state.id
}

output "state_bucket_arn" {
  description = "ARN of the S3 state bucket"
  value       = aws_s3_bucket.terraform_state.arn
}

output "state_bucket_region" {
  description = "Region the bucket was created in - use as 'region' in backend.tf"
  value       = aws_s3_bucket.terraform_state.region
}

# Convenience output - paste this block directly into any environment's backend.tf
output "backend_config_snippet" {
  description = "Ready-to-paste backend block. Replace KEY with the environment path."
  value       = <<-EOT

    terraform {
      backend "s3" {
        bucket         = "${aws_s3_bucket.terraform_state.id}"
        key            = "ENVIRONMENT/REGION/terraform.tfstate"
        region         = "${aws_s3_bucket.terraform_state.region}"
        encrypt        = true
        use_lockfile   = true
      }
    }

    Replace KEY examples:
      dev/us-east-1/terraform.tfstate
      staging/us-east-1/terraform.tfstate
      prod/us-east-1/terraform.tfstate
      prod/us-west-2/terraform.tfstate
  EOT
}
