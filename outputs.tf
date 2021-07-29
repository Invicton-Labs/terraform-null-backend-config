output "backend" {
  description = "The backend configuration (`null` if no backend has been configured)."
  value       = local.backend
}

output "workspace" {
  description = "The currently active workspace (`null` if none configured/selected)."
  value       = local.workspace
}

output "output_state" {
  description = "The current (pre-apply) Terraform state of this configuration, as provided by the `terraform_remote_state` data source. If no backend is configured or the `fetch_output_state` variable is set to `false`, this value will be `null`."
  value       = length(data.terraform_remote_state.state) > 0 ? data.terraform_remote_state.state[0].outputs : null
}

output "raw_state" {
  description = "The raw, current (pre-apply) Terraform state of this configuration, as stored in the terraform.tfstate file (or remote equivalent). If no backend is configured or the `fetch_raw_state` variable is set to `false`, this value will be `null`."
  value       = local.raw_state
}
