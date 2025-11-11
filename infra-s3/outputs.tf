output "bucket_name" {
  description = "Name of the S3 bucket."
  value       = aws_s3_bucket.results.id
}

output "bucket_region" {
  description = "AWS region of the bucket (from variable)."
  value       = var.region
}

output "lifecycle_rule_id" {
  description = "Lifecycle rule ID for the 'midlertidig' prefix."
  value       = aws_s3_bucket_lifecycle_configuration.results.rule[0].id
}