terraform {
  required_version = ">= 0.13.0"
}

locals {
  base_dir = var.working_dir != null ? var.working_dir : path.root
  // This file always exists for all initialized installations
  init_dir           = "${local.base_dir}/.terraform"
  backend_path       = "${local.init_dir}/terraform.tfstate"
  workspace_path     = "${local.init_dir}/environment"
  backend_found      = fileexists(local.backend_path)
  backend_contents   = local.backend_found ? jsondecode(file(local.backend_path)) : null
  backend            = local.backend_found ? lookup(local.backend_contents, "backend", null) : null
  backend_configured = local.backend != null
  workspace          = fileexists(local.workspace_path) ? file(local.workspace_path) : null
  supported_backends = [
    "s3",
    "local"
  ]
}

// Fetch the state, if desired
data "terraform_remote_state" "state" {
  count     = local.backend_configured && var.fetch_output_state ? 1 : 0
  backend   = local.backend.type
  config    = local.backend.config
  workspace = local.workspace
}

// Ensure that the backend type is supported
module "assert_valid_backend" {
  source        = "Invicton-Labs/assertion/null"
  version       = "0.1.2"
  condition     = var.fetch_raw_state && local.backend_configured ? contains(local.supported_backends, local.backend.type) : true
  error_message = local.backend_configured ? "The '${local.backend.type}' backend type is not supported for the 'Invicton-Labs/backend-config/null' module." : null
}

locals {
  raw_states = [
    local.default_state,
    local.s3_state
  ]
  non_null_raw_states = [
    for state in local.raw_states :
    state
    if state != null
  ]
  raw_state = length(local.non_null_raw_states) > 0 ? local.non_null_raw_states[0] : null
}
