output "replication_role_arn" {
  value       = aws_iam_role.replication.arn
  description = "ARN of the replication role (use in destination account bucket policy)"
}
