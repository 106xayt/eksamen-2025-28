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

resource "aws_s3_bucket_public_access_block" "results" {
  bucket                  = aws_s3_bucket.results.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "results" {
  bucket = aws_s3_bucket.results.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "results" {
  bucket = aws_s3_bucket.results.id
  count  = var.enable_versioning ? 1 : 0
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "results" {
  bucket = aws_s3_bucket.results.id

  rule {
    id     = "midlertidig-tier-expire"
    status = "Enabled"

    filter {
      prefix = "midlertidig/"
    }

    dynamic "transition" {
      for_each = var.enable_glacier_tiering ? [1] : []
      content {
        days          = var.days_to_glacier
        storage_class = "GLACIER"
      }
    }

    expiration {
      days = var.days_to_expire
    }
  }
}