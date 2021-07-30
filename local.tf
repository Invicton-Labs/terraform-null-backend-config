locals {
  default_state_path  = "${path.root}/terraform.tfstate"
  default_state_found = fileexists(local.default_state_path)
  is_local_explicit   = local.backend_configured ? (local.backend.type == "local" ? true : false) : false
  is_local            = local.is_local_explicit ? true : !local.backend_configured && local.default_state_found
  local_state_path    = local.is_local_explicit ? local.backend.config.path : local.default_state_path
}

module "read_local_state" {
  count           = local.default_state_found ? 1 : 0
  source          = "Invicton-Labs/shell-data/external"
  version         = "0.1.6"
  command_unix    = "cat $STATE_FILE"
  command_windows = "Get-Content -Path $Env:STATE_FILE"
  working_dir     = path.root
  fail_on_error   = false
  environment = {
    STATE_FILE = local.local_state_path
  }
}

// Ensure that if the default backend is being used, the file isn't locked
module "assert_default_unlocked" {
  source        = "Invicton-Labs/assertion/null"
  version       = "0.1.2"
  condition     = var.fetch_raw_state && length(module.read_local_state) > 0 ? module.read_local_state[0].exitstatus == 0 : true
  error_message = var.fetch_raw_state && length(module.read_local_state) > 0 ? "The local state file could not be read, probably because Terraform has locked it. Try running terraform plan/apply with the -lock=false option." : null
}

locals {
  default_state = var.fetch_raw_state && length(module.read_local_state) > 0 && module.assert_default_unlocked.checked ? (module.read_local_state[0].exitstatus == 0 ? jsondecode(module.read_local_state[0].stdout) : null) : null
}
