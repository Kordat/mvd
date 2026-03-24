locals {
  participant-did = "did:web:${var.participant}-identityhub.${var.participant}%3A7083:${var.participant}"
  database_url    = "jdbc:postgresql://${var.postgres_endpoint}:${var.postgres_port}/${var.participant}"
  vault_url       = "http://${var.participant}-vault:8200"

  eks_oidc = trimprefix(
    data.aws_eks_cluster.eks.identity[0].oidc[0].issuer,
    "https://"
  )

  controlplane_image = "${var.ecr_prefix}-controlplane:${var.ecr_tag}"
  dataplane_image    = "${var.ecr_prefix}-dataplane:${var.ecr_tag}"
  identityhub_image  = "${var.ecr_prefix}-identity-hub:${var.ecr_tag}"
}
