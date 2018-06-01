variable "server_port" {
  description = "The port the web server will use for http requests"
  type        = "string"
}

variable "region" {
  description = "The region where to deploy"
}

variable "env" {
  description = "The environement (prod/dev/hml/test)"
}

variable "cluster_name" {
  description = "The name of the cluster to deploy"
}

variable "asg_min_size" {
  description = "Minimum count of instance in the ASG"
}

variable "asg_max_size" {
  description = "Maximum count of instance in the ASG"
}

variable "instance_type" {
  description = "Instance type used in the ASG"
}

data "aws_availability_zones" "all" {}
