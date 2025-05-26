locals {
  github_repositories = {
    for name, repo_config in var.github_repositories : name => merge(var.default_repository_config, repo_config)
  }
  repository_rulesets = flatten([
    for repository_name, repository_config in local.github_repositories : [
      for ruleset in repository_config.ruleset :
      merge(
        merge(
          var.default_repository_ruleset_config,
          ruleset,
        ),
        {
          repository                 = repository_name
          require_code_owner_reviews = repository_config.require_code_owner_reviews
          archivedrepository         = repository_config.archived
        }
      )
    ]
  ])
}

resource "github_repository" "repo" {
  # checkov:skip=CKV_GIT_1: Script provides option to create public repositories
  # checkov:skip=CKV2_GIT_1: Script provides option to create branch protection
  for_each    = local.github_repositories
  name        = each.key
  description = each.value.description
  auto_init   = true

  visibility             = each.value.visibility
  gitignore_template     = each.value.gitignore_template
  is_template            = each.value.is_template
  delete_branch_on_merge = each.value.delete_branch_on_merge

  dynamic "template" {
    for_each = each.value.repository_template != null ? { template = each.value.repository_template } : {}
    content {
      owner      = template.value.owner
      repository = template.value.repository
    }
  }

  allow_update_branch       = each.value.allow_update_branch
  allow_auto_merge          = each.value.allow_auto_merge
  allow_merge_commit        = each.value.allow_merge_commit
  allow_squash_merge        = each.value.allow_squash_merge
  squash_merge_commit_title = each.value.squash_merge_commit_title
  allow_rebase_merge        = each.value.allow_rebase_merge
}

resource "github_repository_ruleset" "ruleset" {
  for_each = {
    for ruleset in local.repository_rulesets :
    "${ruleset.repository}.${ruleset.name}" => ruleset if ruleset.archivedrepository == null || ruleset.archivedrepository == false
  }
  name        = each.value.name
  repository  = github_repository.repo[each.value.repository].name
  target      = each.value.target
  enforcement = each.value.enforcement

  dynamic "conditions" {
    for_each = each.value.conditions
    content {
      ref_name {
        include = conditions.value.include
        exclude = conditions.value.exclude
      }
    }
  }

  rules {
    creation                = each.value.creation
    update                  = each.value.update
    deletion                = each.value.deletion
    required_linear_history = each.value.required_linear_history
    required_signatures     = each.value.required_signatures

    dynamic "required_deployments" {
      for_each = each.value.required_deployments
      content {
        required_deployment_environments = required_deployments.value.required_deployment_environments
      }
    }
    dynamic "pull_request" {
      for_each = each.value.pull_requests
      content {
        required_approving_review_count = pull_request.value.required_approving_review_count
        require_code_owner_review       = pull_request.value.require_code_owner_reviews
      }
    }
    dynamic "required_status_checks" {
      for_each = each.value.required_status_checks
      content {
        strict_required_status_checks_policy = required_status_checks.value.strict_required_status_checks_policy
        do_not_enforce_on_create             = required_status_checks.value.do_not_enforce_on_create
        dynamic "required_check" {
          for_each = required_status_checks.value.required_check
          content {
            context        = required_check.value.context
            integration_id = required_check.value.integration_id
          }
        }
      }
    }
  }
  depends_on = [github_repository.repo]
}

resource "github_branch_default" "self" {
  depends_on = [
    github_repository.repo
  ]
  for_each = local.github_repositories

  repository = each.key
  branch     = each.value.default_branch
}
