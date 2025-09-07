variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "alb_name" {
  description = "Name of the ALB"
  type        = string
}

variable "target_group_name" {
  description = "Name of the target group"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "s3_bucket_id" {
  description = "S3 bucket ID for access logs"
  type        = string
}

variable "target_port" {
  description = "Target port for the target group"
  type        = number
  default     = 8080
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/health"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}