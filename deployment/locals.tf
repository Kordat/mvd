locals {
    issuer_image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.eu-west-1.amazonaws.com/${var.project}-${var.environment}-issuerservice:${var.ecr_tag}"
}
