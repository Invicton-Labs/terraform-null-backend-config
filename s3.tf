locals {
  is_s3 = local.backend_configured ? (local.backend.type == "s3" ? true : false) : false
}

provider "aws" {
  alias      = "backend"
  access_key = local.is_s3 ? local.backend.config.access_key : "1"
  secret_key = local.is_s3 ? local.backend.config.secret_key : "A"
  region     = local.is_s3 ? local.backend.config.region : "us-east-1"
  profile    = local.is_s3 ? local.backend.config.profile : null
  assume_role {
    duration_seconds    = local.is_s3 ? local.backend.config.assume_role_duration_seconds : null
    external_id         = local.is_s3 ? local.backend.config.external_id : null
    policy              = local.is_s3 ? local.backend.config.assume_role_policy : null
    policy_arns         = local.is_s3 ? local.backend.config.assume_role_policy_arns : null
    role_arn            = local.is_s3 ? local.backend.config.role_arn : null
    session_name        = local.is_s3 ? local.backend.config.session_name : null
    tags                = local.is_s3 ? local.backend.config.assume_role_tags : null
    transitive_tag_keys = local.is_s3 ? local.backend.config.assume_role_transitive_tag_keys : null
  }
  endpoints {
    iam      = local.is_s3 ? local.backend.config.iam_endpoint : null
    dynamodb = local.is_s3 ? local.backend.config.dynamodb_endpoint : null
    sts      = local.is_s3 ? local.backend.config.sts_endpoint : null
    s3       = local.is_s3 ? local.backend.config.endpoint : null
  }
  shared_credentials_file     = local.is_s3 ? local.backend.config.shared_credentials_file : null
  token                       = local.is_s3 ? local.backend.config.token : null
  max_retries                 = local.is_s3 ? local.backend.config.max_retries : null
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_requesting_account_id  = true
  s3_force_path_style         = local.is_s3 ? local.backend.config.force_path_style : null
}

data "aws_s3_bucket_object" "state" {
  count    = local.is_s3 && var.fetch_raw_state ? 1 : 0
  provider = aws.backend
  bucket   = local.backend.config.bucket
  key      = local.backend.config.key
}

locals {
  s3_state = length(data.aws_s3_bucket_object.state) > 0 ? jsondecode(data.aws_s3_bucket_object.state[0].body) : null
}
