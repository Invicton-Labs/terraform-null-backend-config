variable "working_dir" {
  description = "The working directory to use for determining the init configuration. Defaults to the `path.root` directory (configuration of the parent Terraform configuration being planned/applied)."
  type        = string
  default     = null
}

variable "fetch_output_state" {
  description = "Whether the current (pre-apply) Terraform state of this configuration should be retrieved, as provided by the `terraform_remote_state` data source."
  type        = bool
  default     = false
}

variable "fetch_raw_state" {
  description = "Whether the raw, current (pre-apply) Terraform state of this configuration should be retrieved, as stored in the terraform.tfstate file (or remote equivalent)."
  type        = bool
  default     = false
}
