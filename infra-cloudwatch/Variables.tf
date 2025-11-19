//variables
variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "eu-west-1"
}

variable "metrics_namespace" {
  description = "CloudWatch namespace for custom metrics"
  type        = string
  default     = "kandidat-28"
}

variable "candidate_dimension" {
  description = "Value used in the 'candidate' dimension on metrics"
  type        = string
  default     = "28"
}

variable "alarm_email" {
  description = "Email address that should receive CloudWatch alarm notifications via SNS"
  type        = string
}