output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.analysis.bucket
}

output "bucket_region" {
  description = "Region where the bucket is created"
  value       = var.region
}

output "lifecycle_rule_id" {
  description = "ID of the lifecycle rule that targets midlertidig/"
  value       = "midlertidig-rule"
}
output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.analysis.bucket
}

output "bucket_region" {
  description = "Region where the bucket is created"
  value       = var.region
}

output "lifecycle_rule_id" {
  description = "ID of the lifecycle rule that targets midlertidig/"
  value       = "midlertidig-rule"
}

# Note: lifecycle_resource_id removed to avoid deprecated attribute warnings.
