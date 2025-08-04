variable "vpc_id" {
  type        = string
  description = "vpc id"
}

variable "cidr_block" {
  type        = string
  description = "cidr block"
}

variable "availability_zone" {
  type        = string
  description = "availability zone"
}

variable "map_public_ip_on_launch" {
  type        = bool
  description = "map public ip on launch"
}

variable "name" {
  type        = string
  description = "subnet name"
}
