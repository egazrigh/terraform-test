variable "server_port" {
  description = "The port the web server will use for http requests"
  type        = "string"
  default     = 8080
}

variable "region" {
  description = "The region where to deploy"
  default     = "eu-west-3"
}

variable "env" {
  description = "The environement (prod/dev/hml/test)"
  default     = "prod"
}

variable "cluster_name" {
  description = "The name of the cluster to deploy"
}

data "aws_availability_zones" "all" {}
