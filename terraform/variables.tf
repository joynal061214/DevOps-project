variable "image_uri" {
  description = "Docker image URI for the ECS task"
  type        = string
}
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

variable "app_vpc_id" {
  description = "VPC ID to deploy resources into"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs to deploy resources into"
  type        = list(string)
}

