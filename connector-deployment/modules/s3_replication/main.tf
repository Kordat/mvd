#
# Per-participant S3 replication: source bucket -> destination participant bucket (cross-account)
#

data "aws_region" "current" {}

resource "aws_iam_role" "replication" {
  name = "kordat-${var.environment}-${var.participant}-s3-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "replication" {
  name = "s3-replication-to-${var.participant}"
  role = aws_iam_role.replication.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket"
        ]
        Resource = var.source_bucket_arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging"
        ]
        Resource = "${var.source_bucket_arn}/*"
      },
      {
        Effect   = "Allow"
        Action   = ["kms:Decrypt"]
        Resource = [var.kms_key_arn]
        Condition = {
          StringLike = {
            "kms:ViaService" = "s3.${data.aws_region.current.id}.amazonaws.com"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ]
        Resource = "arn:aws:s3:::${var.destination_bucket_name}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_replication_configuration" "to_participant" {
  bucket = var.source_bucket_id
  role   = aws_iam_role.replication.arn

  rule {
    id     = "replicate-to-${var.participant}-destination"
    status = "Enabled"

    filter {}

    destination {
      bucket        = "arn:aws:s3:::${var.destination_bucket_name}"
      account       = var.destination_account_id
      storage_class = "STANDARD"

      access_control_translation {
        owner = "Destination"
      }

      metrics {
        status = "Enabled"
      }
    }
  }
}
