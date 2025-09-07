variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "image_uri" {
  description = "Docker image URI"
  type        = string
}

variable "app_vpc_id" {
  description = "VPC ID for the application"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "ResourceCreator" {
  description = "Resource creator email"
  type        = string
#  default     = "joynal.abedin@gmx.co.uk"
}