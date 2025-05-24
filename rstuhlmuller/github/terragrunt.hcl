include "root" {
  path = find_in_parent_folders("root.hcl")
}
include "github_provider" {
  path = "${dirname(find_in_parent_folders("root.hcl"))}/common/providers/github.hcl"
}
include "github" {
  path = "${dirname(find_in_parent_folders("root.hcl"))}/common/github.hcl"
}

locals {
  org_vars = read_terragrunt_config(find_in_parent_folders("organization.hcl")).locals
}

inputs = {
  default_repository_config        = local.org_vars.default_repository_config
  default_branch_protection_config = local.org_vars.default_branch_protection_config
  github_repositories = {
    homelab = {
      description = "Kubernetes homelab deployment"
      visibility  = "public"
    }
  }
}