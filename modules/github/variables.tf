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
    ruleset                   = list(any)
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
    ruleset                    = [{ name = "main" }]
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

variable "default_repository_ruleset_config" {
  type = object({
    name                       = string
    target                     = string
    enforcement                = string
    require_code_owner_reviews = bool
    require_signed_commits     = bool
    conditions = set(object({
      include = list(string)
      exclude = list(string)
    }))
    creation                = bool
    update                  = bool
    deletion                = bool
    required_linear_history = bool
    required_signatures     = bool
    bypass_actors = set(object({
      actor_id    = number
      actor_type  = string
      bypass_mode = string
    }))
    required_deployments = set(object({
      required_deployment_environments = list(string)
    }))
    required_status_checks = optional(set(object({
      strict_required_status_checks_policy = optional(bool)
      do_not_enforce_on_create             = optional(bool)
      required_check = set(object({
        context        = string
        integration_id = optional(string)
      }))
    })))
    pull_requests = set(any)
  })
  default = {
    name                       = ""
    target                     = "branch"
    enforcement                = "active"
    require_code_owner_reviews = true
    require_signed_commits     = true
    conditions = [
      {
        include = ["~DEFAULT_BRANCH"]
        exclude = []
      }
    ]
    creation                = true
    update                  = false
    deletion                = true
    required_linear_history = true
    required_signatures     = true
    bypass_actors           = []
    required_deployments    = []
    required_status_checks  = []
    pull_requests           = []
  }
  description = "Default settings for a branch ruleset. This is merged with the ruleset configuration for each repository."
}
