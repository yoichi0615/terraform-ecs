variable "env" {
  description = "The environment name"
  type        = string
}

variable "private_subnet_ids" {
  description = "A list of private subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "db_username" {
  description = "The username for the database"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "The password for the database"
  type        = string
  sensitive   = true
}

variable "instance_class" {
  description = "The instance class for the database"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "The allocated storage for the database"
  type        = number
  default     = 20
}

variable "engine" {
  description = "The database engine"
  type        = string
  default     = "mysql"
}

variable "engine_version" {
  description = "The database engine version"
  type        = string
  default     = "8.0"
}
