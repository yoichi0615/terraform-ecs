resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&'()*+,-.:;<=>?_`{|}~"
}

resource "aws_secretsmanager_secret" "main" {
  name = var.secret_name
}

resource "aws_secretsmanager_secret_version" "main" {
  secret_id     = aws_secretsmanager_secret.main.id
  secret_string = random_password.password.result
}
