variable "github_codestar_connection_arn" {
  type    = string
  default = "arn:aws:codeconnections:ca-central-1:373609202462:connection/b86b82c2-f1e6-438d-8297-4e0c1bf47e00"
}

variable "github_repository_id" {
  type = string
}

variable "github_main_branch" {
  type    = string
  default = "master"
}

variable "account_id" {
  type    = string
  default = "373609202462"
}

variable "region" {
  type    = string
  default = "ca-central-1"
}

variable "app_name" {
  type = string
}
