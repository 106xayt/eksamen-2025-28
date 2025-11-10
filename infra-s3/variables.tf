variable "bucket_name" {
  description = "Name of the S3 bucket. Override with TF_VAR_bucket_name or via workspace variables. Default uses the candidate-specific name; change for your environment."
  type        = string
  default     = "kandidat-28-data"
}

variable "region" {
  description = "AWS region to create resources in"
  type        = string
  default     = "eu-west-1"
}

variable "days_to_glacier" {
  description = "Number of days after which objects under midlertidig/ are transitioned to cheaper storage"
  type        = number
  default     = 30
}

variable "days_to_expire" {
  description = "Number of days after which objects under midlertidig/ are expired (deleted)"
  type        = number
  default     = 90
}

variable "enable_glacier_tiering" {
  description = "Whether to transition temporary objects to Glacier storage class"
  type        = bool
  default     = true
}

variable "enable_versioning" {
  description = "Enable S3 bucket versioning (optional). Off by default for safety."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Map of tags to apply to resources"
  type        = map(string)
  default = {
    Owner       = "aiAlpha"
    Environment = "dev"
  }
}
variable "bucket_name" {
  description = "Name of the S3 bucket. Override with TF_VAR_bucket_name or via workspace variables. Default uses the candidate-specific name; change for your environment."
  type        = string
  default     = "kandidat-28-data"
}

variable "region" {
  description = "AWS region to create resources in"
  type        = string
  default     = "eu-west-1"
}

variable "days_to_glacier" {
  description = "Number of days after which objects under midlertidig/ are transitioned to cheaper storage"
  type        = number
  default     = 30
}

variable "days_to_expire" {
  description = "Number of days after which objects under midlertidig/ are expired (deleted)"
  type        = number
  default     = 90
}

variable "enable_glacier_tiering" {
  description = "Whether to transition temporary objects to Glacier storage class"
  type        = bool
  default     = true
}

variable "enable_versioning" {
  description = "Enable S3 bucket versioning (optional). Off by default for safety."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Map of tags to apply to resources"
  type        = map(string)
  default = {
    Owner       = "aiAlpha"
    Environment = "dev"
  }
}
