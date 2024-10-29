variable "prefix" {
  description = "Prefix for all resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public Subnet IDs"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "ALB Security Group ID"
  type        = string
}
