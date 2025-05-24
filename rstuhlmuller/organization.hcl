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
}