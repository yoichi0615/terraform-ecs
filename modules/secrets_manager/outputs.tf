output "secret_string" {
  value = data.aws_secretsmanager_secret_version.rds_password_version.secret_string
}
