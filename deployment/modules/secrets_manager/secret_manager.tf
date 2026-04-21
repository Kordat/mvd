data "aws_kms_secrets" "secrets" {
  # Fetch only the secrets that need encryption
  dynamic "secret" {
    for_each = { for each in var.secrets : each.name => each.value if each.encrypted }
    iterator = secret
    content {
      name    = secret.key
      payload = secret.value
    }
  }
}

locals {
  # Merge encrypted and plain secrets
  secret_values = { for each in var.secrets : each.name => (
    each.encrypted ? data.aws_kms_secrets.secrets.plaintext[each.name] : each.value
  ) }
}

resource "aws_secretsmanager_secret" "secret" {
  name = "${var.project}-${var.environment}-${var.name}"

  tags = {
    Name        = "${var.project}-${var.environment}-${var.name}"
    project      = var.project
    environment = var.environment
    application = var.application
  }
}

resource "aws_secretsmanager_secret_version" "secret_version" {
  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = jsonencode(local.secret_values)
}