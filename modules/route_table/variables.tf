variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet to associate the route table with"
  type        = string
}

variable "gateway_id" {
  description = "The ID of the gateway to route traffic to"
  type        = string
  default     = null
}

variable "nat_gateway_id" {
  description = "The ID of the NAT gateway to route traffic to"
  type        = string
  default     = null
}

variable "name" {
  description = "The name of the route table"
  type        = string
}
