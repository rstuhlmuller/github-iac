locals {
  github_repositories = {
    for name, repo_config in var.github_repositories : name => merge(var.default_repository_config, repo_config)
  }
  repository_protected_branches = flatten([
    for repository_name, repository_config in local.github_repositories : [
      for protected_branch in repository_config.protected_branches :
      merge(
        merge(
          var.default_branch_protection_config,
          protected_branch,
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

resource "github_branch_protection" "repo" {
  #checkov:skip=CKV_GIT_5:Defaults to double enforcement
  #checkov:skip=CKV_GIT_6:No need to force signed commit
  for_each = {
    for branch in local.repository_protected_branches :
    "${branch.repository}.${branch.name}" => branch if branch.archivedrepository == null || branch.archivedrepository == false
  }
  repository_id          = github_repository.repo[each.value.repository].node_id
  pattern                = each.value.name
  require_signed_commits = each.value.require_signed_commits

  dynamic "required_pull_request_reviews" {
    for_each = try(each.value.require_pull_request_reviews, true) != false ? toset([1]) : toset([])
    content {
      required_approving_review_count = each.value.required_approving_review_count
      dismiss_stale_reviews           = each.value.dismiss_stale_reviews
      require_code_owner_reviews      = each.value.require_code_owner_reviews
      require_last_push_approval      = each.value.require_last_push_approval
    }
  }

  dynamic "required_status_checks" {
    for_each = each.value.required_status_checks != [] ? toset(["each.value.repository"]) : toset([])
    content {
      strict   = each.value.required_status_checks_are_strict
      contexts = each.value.required_status_checks
    }
  }
}

resource "github_branch_default" "self" {
  depends_on = [
    github_repository.repo
  ]
  for_each = local.github_repositories

  repository = each.key
  branch     = each.value.default_branch
}
