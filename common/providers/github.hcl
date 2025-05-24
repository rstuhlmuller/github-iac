locals {
  org_vars     = read_terragrunt_config(find_in_parent_folders("organization.hcl"))
  organization = local.org_vars.locals.organization
}

generate "provider" {
  path      = "tg-provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
  provider "aws" {region = "us-east-1"}
  data "aws_ssm_parameter" "github_app_id" {
    name = "/github-iac/app_id"
  }
  data "aws_ssm_parameter" "github_app_installation_id" {
    name = "/github-iac/${local.organization}/app_installation_id"
  }
  data "aws_ssm_parameter" "github_app_pem_file" {
    name = "/github-iac/app_pem_file"
  }

  provider "github" {
    owner = "${local.organization}"
    app_auth {
      id              = data.aws_ssm_parameter.github_app_id.value
      installation_id = data.aws_ssm_parameter.github_app_installation_id.value
      pem_file        = data.aws_ssm_parameter.github_app_pem_file.value
    }
  }
  EOF
}