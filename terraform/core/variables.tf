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
    },
    mongo-api = {
      app_name             = "mongo-api"
      github_repository_id = "bruno7317/cloudweave-mongo-api"
    },
    postgres-api = {
      app_name             = "postgres-api"
      github_repository_id = "bruno7317/cloudweave-postgres-api"
    }
  }
}
