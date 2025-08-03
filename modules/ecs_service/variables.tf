variable "name" {
  description = "The name of the ECS service"
  type        = string
}

variable "cluster_id" {
  description = "The ID of the ECS cluster"
  type        = string
}

variable "task_definition_arn" {
  description = "The ARN of the task definition"
  type        = string
}

variable "desired_count" {
  description = "The desired number of tasks"
  type        = number
}

variable "subnet_ids" {
  description = "A list of subnet IDs for the ECS service"
  type        = list(string)
}

variable "security_group_ids" {
  description = "A list of security group IDs for the ECS service"
  type        = list(string)
}

variable "lb_target_group_arn" {
  description = "The ARN of the load balancer target group"
  type        = string
}

variable "container_name" {
  description = "The name of the container"
  type        = string
}

variable "container_port" {
  description = "The port the container listens on"
  type        = number
}
