terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.91.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = var.region
}

module "cloudweave_pipeline" {
  for_each = var.pipelines
  source   = "./pipeline"

  app_name             = each.value.app_name
  github_repository_id = each.value.github_repository_id
}
