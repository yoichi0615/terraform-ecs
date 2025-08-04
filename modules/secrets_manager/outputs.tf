output "secret_string" {
  description = "The secret string"
  value       = aws_secretsmanager_secret_version.main.secret_string
  sensitive   = true
}
