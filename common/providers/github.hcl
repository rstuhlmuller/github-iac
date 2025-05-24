locals {
  org_vars     = read_terragrunt_config(find_in_parent_folders("organization.hcl"))
  organization = local.org_vars.locals.organization
}

generate "provider" {
  path      = "tg-provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
  provider "github" {
    owner = "${local.organization}"
  }
  EOF
}