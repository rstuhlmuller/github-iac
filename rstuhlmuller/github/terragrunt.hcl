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
  default_repository_config         = local.org_vars.default_repository_config
  default_repository_ruleset_config = local.org_vars.default_repository_ruleset_config
  github_repositories = {
    # Bootstrap this repo
    github-iac = {
      description = "Infrastructure as Code for Github Repositories"
      visibility  = "public"
    }
    homelab = {
      description = "Kubernetes homelab deployment"
      visibility  = "public"
    }
    octobot-deploy = {
      description = "Helm charts for OctoBot"
      visibility = "public"
    }
    openwebui-helm-charts = {
      description = "Helm charts for OpenWebUI with MCPO sidecar"
      visibility  = "public"
    }
    personal-website = {
      description = "Personal website"
      visibility  = "public"
      ruleset = [{
        name = "main" 
        required_signatures = false
        bypass_actors = [{
          actor_id    = 5
          actor_type  = "RepositoryRole"
          bypass_mode = "always"
        }]
      }]
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