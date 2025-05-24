include "root" {
  path = find_in_parent_folders("root.hcl")
}
include "github_provider" {
  path = "${dirname(find_in_parent_folders("root.hcl"))}/common/providers/github.hcl"
}

terraform {
  source = "${get_repo_root()}//modules/github"
}

locals {
  org_vars = read_terragrunt_config(find_in_parent_folders("organization.hcl")).locals
}

inputs = {
  default_repository_config = local.org_vars.default_repository_config
  github_repositories = {
    homelab = {
      description = "Kubernetes homelab deployment"
      visibility  = "public"
    }
    personal-webiste = {
      description = "Personal website"
      visibility  = "public"
    }
    personal-website-api = {
      description = "Personal website API"
      visibility  = "public"
    }
    workflows = {
      description = "GitHub workflows for the organization"
      visibility  = "public"
    }
  }
}