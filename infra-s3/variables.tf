variable "region" {
  description = "AWS region to create resources in."
  type        = string
  default     = "eu-west-1"
}

variable "bucket_name" {
  description = "S3 bucket name for analysis results. Must be globally unique."
  type        = string
  default     = "kandidat-<nr>-data"
}

variable "enable_versioning" {
  description = "Enable S3 versioning for the bucket."
  type        = bool
  default     = false
}

variable "enable_glacier_tiering" {
  description = "Enable transition to cheaper storage for files under the 'midlertidig/' prefix."
  type        = bool
  default     = true
}

variable "days_to_glacier" {
  description = "Number of days before transitioning 'midlertidig/' objects to cheaper storage."
  type        = number
  default     = 7
}

variable "days_to_expire" {
  description = "Number of days before expiring (deleting) 'midlertidig/' objects."
  type        = number
  default     = 30
}