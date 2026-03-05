# s3_replication

Per-participant S3 replication: replicates from this participant's assets bucket to a destination bucket in another AWS account (e.g. GDM).

## Isolation

This module is **isolated per participant**. It is invoked once per connector-deployment run, and only when:

- `replicate_to_participant = true`
- `participant_account_id` and `participant_bucket_name` are set

Each participant has separate Terraform state (`infra/kordat/<PARTICIPANT>/terraform.tfstate`), so replication resources are created only for participants that need them.

## Resources

- IAM role: `kordat-{env}-{participant}-s3-replication-role`
- IAM policy: read from source bucket, decrypt KMS, write to destination
- S3 replication configuration on the participant's assets bucket

## Usage

Enable replication by setting in `terraform.tfvars` (or via -var) for the target participant:

```hcl
replicate_to_participant  = true
participant_account_id    = "123456789012"
participant_bucket_name   = "gdm-pre-backend-bucket"
```

The destination account must have a bucket policy allowing this role to replicate.
