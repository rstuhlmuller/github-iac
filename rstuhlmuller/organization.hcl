locals {
  organization = "rstuhlmuller"

  default_repository_config = {
    description                = ""
    visibility                 = "private"
    gitignore_template         = null
    default_branch             = "main"
    require_code_owner_reviews = false
    is_template                = false
    ruleset                    = [{ name = "main" }]
    delete_branch_on_merge     = true
    allow_update_branch        = false
    allow_auto_merge           = false
    allow_merge_commit         = false
    allow_squash_merge         = false
    squash_merge_commit_title  = "COMMIT_OR_PR_TITLE"
    allow_rebase_merge         = false
    allow_update_branch        = true
    allow_squash_merge         = true
    archived                   = false
  }
  default_branch_protection_config = {
    dismiss_stale_reviews             = true
    require_conversation_resolution   = false
    require_last_push_approval        = false
    require_pull_request_reviews      = false
    required_approving_review_count   = 2
    require_signed_commits            = true
    required_linear_history           = false
    required_status_checks            = []
    required_status_checks_are_strict = false
  }
}