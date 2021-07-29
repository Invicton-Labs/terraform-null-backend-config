# Terraform Backend Config
Retrieves the current `terraform init` configuration (including backend config and workspace).

What might you use this for? We're not entirely sure. It definitely accesses information that HashiCorp didn't intend for us to have or do anything with, but we've found some use cases:
- Use the backend configuration to create a `provider` that has the same permissions/access as the internal provider Terraform uses for the backend
- Using a provider with the backend configuration, combined with data about where the state is stored (e.g. which S3 bucket and object) to load the raw state data for use in the configuration (be warned, this is a MAJOR hack)

Current state:
- The backend config should work for all backend types and workspace settings
- The `output_state` should work for all backend types and workspace settings
- The `raw_state` should work for `S3` and `local` backend types (for `local` backends, `terraform plan` and `terraform apply` must be run with `-lock=false`)

Usage:
```
module "backend_config" {
  source  = "Invicton-Labs/backend-config/null"
  fetch_output_state = true
  // Currently only supported for S3 and local backends
  fetch_raw_state = false
}

output "backend_config" {
    value = module.init_config
}
```

Result:
```
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

backend_config = {
  "backend" = {
      type = "s3"
      config = {
          bucket = "..."
          ...
      }
  }
  "output_state" = {
      // Equivalent output to the terraform_remote_state data source's `outputs` field
  }
  "raw_state" = null
  "workspace" = "myworkspace"
}
```
