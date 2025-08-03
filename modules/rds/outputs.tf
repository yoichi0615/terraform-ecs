output "db_instance_address" {
  description = "The address of the DB instance"
  value       = aws_db_instance.main.address
}

output "db_instance_port" {
  description = "The port of the DB instance"
  value       = aws_db_instance.main.port
}
