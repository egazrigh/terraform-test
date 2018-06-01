variable "db_password" {
  "description" = "The password for the database (min 8 chars)"
}

variable "region" {
  description = "The region where to deploy"
}

variable "env" {
  description = "The environement (prod/dev/hml/test)"
}

variable "cluster_name" {
  description = "The name to use for all the cluster resources"
}
