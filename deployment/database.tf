resource "random_password" "issuer_password" {
  length           = 16
  special          = true
  override_special = "!#$%&()-_=+[]{}<>?"
}

provider "postgresql" {
  host            = data.aws_db_instance.rds.address
  port            = var.postgres_port
  database        = "participants"
  username        = "dbadmin"
  password        = var.postgres_admin_password
  sslmode         = "require"
  connect_timeout = 15
  superuser       = false
}

resource "postgresql_role" "issuer_user" {
  name     = var.issuer_name
  login    = true
  password = random_password.issuer_password.result
}

resource "postgresql_database" "issuer_database" {
  name              = var.issuer_name
  owner             = postgresql_role.issuer_user.name
  lc_collate        = "en_US.UTF-8"
  lc_ctype          = "en_US.UTF-8"
  template          = "template0"
  allow_connections = true
}

resource "postgresql_grant" "db_privs" {
  database    = postgresql_database.issuer_database.name
  role        = postgresql_role.issuer_user.name
  object_type = "database"
  privileges  = ["CONNECT", "CREATE", "TEMPORARY"]
}

resource "postgresql_grant" "schema_privs" {
  database    = postgresql_database.issuer_database.name
  role        = postgresql_role.issuer_user.name
  schema      = "public"
  object_type = "schema"
  privileges  = ["CREATE", "USAGE"]
}

# Crea la tabla membership_attestations y los datos semilla del issuer
resource "postgresql_script" "issuer_schema_and_seeds" {
  depends_on = [
    postgresql_grant.db_privs,
    postgresql_grant.schema_privs,
  ]

  database = postgresql_database.issuer_database.name

  create_script = <<-EOT
    CREATE TABLE IF NOT EXISTS membership_attestations (
      id                    VARCHAR DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
      membership_type       INTEGER DEFAULT 0,
      holder_id             VARCHAR NOT NULL,
      membership_start_date TIMESTAMP DEFAULT now() NOT NULL
    );

    CREATE UNIQUE INDEX IF NOT EXISTS membership_attestation_holder_id_uindex
      ON membership_attestations (holder_id);
  EOT

  delete_script = <<-EOT
    DROP TABLE IF EXISTS membership_attestations;
  EOT
}
