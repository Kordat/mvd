module "s3_replication" {
  count  = local.replication_enabled ? 1 : 0
  source = "./modules/s3_replication"

  participant             = var.participant
  environment             = var.environment
  source_bucket_id        = module.assets_s3_bucket.bucket_id
  source_bucket_arn       = module.assets_s3_bucket.bucket_arn
  kms_key_arn             = module.kms.key_arn
  destination_account_id  = var.participant_account_id
  destination_bucket_name = var.participant_bucket_name
}
