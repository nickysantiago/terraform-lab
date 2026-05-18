# ============================================================
# BOOTSTRAP: main.tf
#
# Run this ONCE before anything else.
# Creates the S3 bucket and DynamoDB table that all other
# Terraform environments use to store and lock state.
#
# IMPORTANT:
#   - This config intentionally has NO backend block.
#   - State is stored locally in this directory.
#   - That local state file is the ONE exception to the
#     "no local state" rule.
#   - Do not run terraform destroy against this config.
# ============================================================

# ── S3 Bucket ─────────────────────────────────────────────────
# Stores all Terraform state files for every environment.
# Versioning is critical - lets you recover from a bad apply
# by restoring a previous state version from S3.

resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-259563981482"

  # Never allow Terraform to delete this bucket.
  # Losing it means losing all state for all environments.
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name      = "Terraform State"
    Purpose   = "terraform-state"
    ManagedBy = "terraform-bootstrap"
  }
}

# Enable versioning - every state file write creates a new version.
# If state gets corrupted you can restore the previous version from S3.
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Encrypt all state files at rest.
# State files can contain sensitive values - always encrypt.
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block all public access to the state bucket.
# State files must never be publicly accessible.
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Automatically expire old state versions after 90 days.
# Versioning accumulates files over time - this keeps costs in check
# while still giving you a 90-day recovery window.
resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  # Wait for versioning to be enabled before applying lifecycle rules
  depends_on = [aws_s3_bucket_versioning.terraform_state]

  rule {
    id     = "expire-old-state-versions"
    status = "Enabled"

    # Empty filter means this rule applies to ALL objects in the bucket.
    # The provider requires either a filter block or a prefix attribute.
    # An empty filter is the correct way to target everything.
    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    # Also clean up incomplete multipart uploads
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

