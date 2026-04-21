#
#  Copyright (c) 2025 Cofinity-X
#
#  This program and the accompanying materials are made available under the
#  terms of the Apache License, Version 2.0 which is available at
#  https://www.apache.org/licenses/LICENSE-2.0
#
#  SPDX-License-Identifier: Apache-2.0
#
#  Contributors:
#       Cofinity-X - initial API and implementation
#

module "dataspace-issuer" {
  source            = "./modules/issuer"
  humanReadableName = "dataspace-issuer-service"
  participantId     = "example" #var.consumer-did
  database = {
    user     = var.issuer_name
    password = "issuer" #random_password.issuer_password.result
    url      = "jdbc:postgresql://${module.dataspace-issuer-postgres.database-url}/issuer" #data.aws_db_instance.rds.endpoint
  }
  image     = local.issuer_image
  vault-url = "http://issuer-vault.${var.project}.svc.cluster.local:8200"
  namespace = var.project
  useSVE    = var.useSVE
}

# issuer vault
module "dataspace-issuer-vault" {
  source            = "./modules/vault"
  humanReadableName = "issuer-vault"
  namespace         = var.project #kubernetes_namespace.ns.metadata.0.name
}

# Postgres database for the consumer
module "dataspace-issuer-postgres" {
  depends_on       = [kubernetes_config_map_v1.issuer-initdb-config]
  source           = "./modules/postgres"
  instance-name    = "issuer"
  init-sql-configs = ["issuer-initdb-config"]
  namespace        = var.project #kubernetes_namespace.ns.metadata.0.name
  image            = "150073872684.dkr.ecr.eu-west-1.amazonaws.com/kordat-dev-postgres:16.3-alpine3.20"
}

# DB initialization for the EDC database
resource "kubernetes_config_map_v1" "issuer-initdb-config" {
  metadata {
    name      = "issuer-initdb-config"
    namespace = var.project #kubernetes_namespace.ns.metadata.0.name
  }
  data = {
    "issuer-initdb-config.sql" = <<-EOT
        CREATE USER issuer WITH ENCRYPTED PASSWORD 'issuer' SUPERUSER;
        CREATE DATABASE issuer;
        \c issuer issuer

        create table if not exists membership_attestations
        (
            membership_type       integer   default 0,
            holder_id             varchar                             not null,
            membership_start_date timestamp default now()             not null,
            id                    varchar   default gen_random_uuid() not null
                constraint attestations_pk
                    primary key
        );

        create unique index if not exists membership_attestation_holder_id_uindex
          on membership_attestations (holder_id);

        -- seed the consumer and provider into the attestations DB, so that they can request FoobarCredentials sourcing
        -- information from the database
        INSERT INTO membership_attestations (membership_type, holder_id) VALUES (1, 'did:web:consumer-identityhub%3A7083:consumer');
        INSERT INTO membership_attestations (membership_type, holder_id) VALUES (2, 'did:web:provider-identityhub%3A7083:provider');
      EOT
  }
}
