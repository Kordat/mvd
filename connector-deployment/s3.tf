module "assets_s3_bucket" {
  source      = "./modules/s3_bucket"
  project     = var.project
  environment = var.environment
  application = "assets"
  bucket_name = "${var.participant}-assets-bucket"
  kms         = module.kms.key_arn
}