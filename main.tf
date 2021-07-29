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
}

// Fetch the state, if desired
data "terraform_remote_state" "state" {
  count     = local.backend_configured && var.fetch_state ? 1 : 0
  backend   = local.backend.type
  config    = local.backend.config
  workspace = local.workspace
}
