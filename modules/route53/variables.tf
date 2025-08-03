variable "zone_name" {
  description = "The name of the Route 53 zone"
  type        = string
}

variable "records" {
  description = "A map of records to create"
  type        = any
  default     = {}
}
