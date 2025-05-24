variable "github_repositories" {
  type        = any
  default     = {}
  description = "A map of GitHub repositories configuration. See default_repository_config variable for the available parameters"
}

variable "default_repository_config" {
  type = object({
    description                = string
    visibility                 = string
    gitignore_template         = string
    default_branch             = string
    require_code_owner_reviews = bool
    is_template                = bool
    repository_template = optional(object({
      owner      = string
      repository = string
    }))
    protected_branches        = list(any)
    delete_branch_on_merge    = bool
    allow_update_branch       = bool
    allow_auto_merge          = bool
    allow_merge_commit        = bool
    allow_squash_merge        = bool
    squash_merge_commit_title = string
    allow_rebase_merge        = bool
    archived                  = bool
  })
  default = {
    description                = ""
    visibility                 = "private"
    gitignore_template         = null
    default_branch             = "main"
    require_code_owner_reviews = false
    is_template                = false
    repository_template        = null
    protected_branches         = [{ name = "main" }]
    delete_branch_on_merge     = true
    allow_update_branch        = false
    allow_auto_merge           = false
    allow_merge_commit         = false
    allow_squash_merge         = false
    squash_merge_commit_title  = "COMMIT_OR_PR_TITLE"
    allow_rebase_merge         = true
    archived                   = false
  }
}

variable "default_branch_protection_config" {
  type = object({
    dismiss_stale_reviews             = bool
    require_conversation_resolution   = bool
    require_last_push_approval        = bool
    require_pull_request_reviews      = bool
    require_signed_commits            = bool
    required_approving_review_count   = number
    required_linear_history           = bool
    required_status_checks            = set(string)
    required_status_checks_are_strict = bool
  })
  default = {
    dismiss_stale_reviews             = true
    require_conversation_resolution   = false
    require_last_push_approval        = false
    require_pull_request_reviews      = true
    require_signed_commits            = true
    required_approving_review_count   = 2
    required_linear_history           = false
    required_status_checks            = []
    required_status_checks_are_strict = true
  }
  description = "Default settings for a branch protection"
}
