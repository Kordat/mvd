# Common variables
variable "project" {
  type        = string
  description = "project name"
}

variable "environment" {
  type        = string
  description = "Environment (dev|pre|pro)"
}

variable "application" {
  type        = string
  description = "Role into the product"
}

# Secret config
variable "name" {
  type        = string
  description = "Secret name"
}

variable "secrets" {
  type = list(object({
    name      = string
    value     = string
    encrypted = bool # Choose if the secret value must be encrypted with KMS
  }))
  description = "Secret content"
}
