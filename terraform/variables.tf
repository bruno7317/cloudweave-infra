variable "region" {
  type    = string
  default = "ca-central-1"
}

variable "pipelines" {
  default = {
    frontend = {
      app_name             = "cloudweave-frontend"
      github_repository_id = "bruno7317/cloudweave-frontend"
    },
    api = {
      app_name             = "cloudweave-api"
      github_repository_id = "bruno7317/cloudweave-api"
    }
  }
}
