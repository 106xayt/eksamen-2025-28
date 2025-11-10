provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "analysis" {
  bucket = var.bucket_name

  tags = merge(var.tags, {
    Name      = var.bucket_name
    Terraform = "true"
  })
}

# Manage bucket ACL using separate resource (the `acl` argument on aws_s3_bucket is deprecated)
resource "aws_s3_bucket_acl" "analysis_acl" {
  bucket = aws_s3_bucket.analysis.bucket
  acl    = "private"
}

# Block public access to the bucket
resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.analysis.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Optional versioning
resource "aws_s3_bucket_versioning" "versioning" {
  count  = var.enable_versioning ? 1 : 0
  bucket = aws_s3_bucket.analysis.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Lifecycle configuration: only applies to prefix 'midlertidig/'
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  bucket = aws_s3_bucket.analysis.bucket

  rule {
    id     = "midlertidig-rule"
    status = "Enabled"

    filter {
      prefix = "midlertidig/"
    }

    transition {
      days          = var.days_to_glacier
      storage_class = var.enable_glacier_tiering ? "GLACIER" : "STANDARD_IA"
    }

    expiration {
      days = var.days_to_expire
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}
