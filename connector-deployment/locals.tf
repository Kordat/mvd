locals {
  participant-did = "did:web:${var.participant}-identityhub.${var.participant}%3A7083:${var.participant}"
  database_url    = "jdbc:postgresql://${data.aws_db_instance.rds.address}:${var.postgres_port}/${var.participant}"
  vault_url       = "http://${var.participant}-vault:8200"

  eks_oidc = trimprefix(
    data.aws_eks_cluster.eks.identity[0].oidc[0].issuer,
    "https://"
  )

  controlplane_image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.eu-west-1.amazonaws.com/${var.project}-${var.environment}-controlplane:${var.ecr_tag}"
  dataplane_image    = "${data.aws_caller_identity.current.account_id}.dkr.ecr.eu-west-1.amazonaws.com/${var.project}-${var.environment}-dataplane:${var.ecr_tag}"
  identityhub_image  = "${data.aws_caller_identity.current.account_id}.dkr.ecr.eu-west-1.amazonaws.com/${var.project}-${var.environment}-identity-hub:${var.ecr_tag}"
}
