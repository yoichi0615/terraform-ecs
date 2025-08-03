variable "family" {
  description = "The family of the task definition"
  type        = string
}

variable "container_image" {
  description = "The Docker image to use for the container"
  type        = string
}

variable "container_port" {
  description = "The port the container listens on"
  type        = number
}

variable "container_name" {
  description = "The name of the container"
  type        = string
}
