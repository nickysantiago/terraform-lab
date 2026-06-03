resource "aws_s3_bucket" "terraform_lab5" {
  bucket = "terraform-lab5-259563981482"

  # Never allow Terraform to delete this bucket.
  # Losing it means losing all state for all environments.
  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name      = "Terraform Lab 5"
    Purpose   = "Server as the backend for Lab 5's state file"
    ManagedBy = "terraform"
  }
}

resource "aws_s3_bucket_versioning" "terraform_lab5" {
  bucket = aws_s3_bucket.terraform_lab5.id

  versioning_configuration {
    status = "Enabled"
  }
}