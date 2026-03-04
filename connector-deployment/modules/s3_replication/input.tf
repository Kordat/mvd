#
# S3 Replication Module - Isolated per participant
# Creates IAM role and replication config for replicating from this participant's
# bucket to a destination participant bucket (cross-account).
#

variable "participant" {
  type        = string
  description = "Participant key (used for role naming)"
}

variable "environment" {
  type        = string
  description = "Environment (dev, pre, pro)"
}

variable "source_bucket_id" {
  type        = string
  description = "ID of the source S3 bucket (this participant's assets bucket)"
}

variable "source_bucket_arn" {
  type        = string
  description = "ARN of the source S3 bucket"
}

variable "kms_key_arn" {
  type        = string
  description = "KMS key ARN for decrypting source objects"
}

variable "destination_account_id" {
  type        = string
  description = "Destination AWS account ID"
}

variable "destination_bucket_name" {
  type        = string
  description = "Destination bucket name in the participant account"
}
