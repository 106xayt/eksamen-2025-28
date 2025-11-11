provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "results" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Project     = "eksamen"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

# Block all public access to the bucket. This is a security best practice.
resource "aws_s3_bucket_public_access_block" "results" {
  bucket                  = aws_s3_bucket.results.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable server‑side encryption with AES256 to protect data at rest.
resource "aws_s3_bucket_server_side_encryption_configuration" "results" {
  bucket = aws_s3_bucket.results.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Optional versioning controlled by variable.
resource "aws_s3_bucket_versioning" "results" {
  bucket = aws_s3_bucket.results.id
  count  = var.enable_versioning ? 1 : 0
  versioning_configuration {
    status = "Enabled"
  }
}

# Lifecycle configuration for objects under the 'midlertidig/' prefix.
resource "aws_s3_bucket_lifecycle_configuration" "results" {
  bucket = aws_s3_bucket.results.id

  rule {
    id     = "midlertidig-tier-expire"
    status = "Enabled"

    filter {
      prefix = "midlertidig/"
    }

    # Transition objects to cheaper storage (e.g., Glacier) if enabled.
    dynamic "transition" {
      for_each = var.enable_glacier_tiering ? [1] : []
      content {
        days          = var.days_to_glacier
        storage_class = "GLACIER"
      }
    }

    # Expire (delete) objects after a certain number of days.
    expiration {
      days = var.days_to_expire
    }
  }
}