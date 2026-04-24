# Current AWS account
data "aws_caller_identity" "current" {}

# RDS data
data "aws_db_instance" "rds" {
  db_instance_identifier = "${var.project}-${var.environment}-participants-database"
}