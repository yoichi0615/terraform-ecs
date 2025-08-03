variable "name" {
  description = "The name for the ALB and related resources"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs for the ALB"
  type        = list(string)
}

variable "security_group_ids" {
  description = "A list of security group IDs for the ALB"
  type        = list(string)
}
