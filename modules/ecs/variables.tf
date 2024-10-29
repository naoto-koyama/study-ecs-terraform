variable "prefix" {
  description = "Prefix for all resources"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private Subnet IDs"
  type        = list(string)
}

variable "ecs_tasks_security_group_id" {
  description = "ECS Tasks Security Group ID"
  type        = string
}

variable "target_group_arn" {
  description = "ALB Target Group ARN"
  type        = string
}

variable "task_cpu" {
  description = "CPU units for the task (1 vCPU = 1024 CPU units)"
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Memory for the task (in MiB)"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Desired count of tasks"
  type        = number
  default     = 2
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 7
}
