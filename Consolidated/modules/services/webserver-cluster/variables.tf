variable "server_port" {
  description = "The port the web server will use for http requests"
  type        = "string"
}

variable "cluster_name" {
  description = "The name to use for all the cluster resources"
}

variable "db_remote_state_bucket" {
  description = "The name of the s3 bucket for the database's remote state"
}

variable "db_remote_state_key" {
  description = "The patch for the database's remote state in S3"
}

variable "region" {
  description = "The region where to deploy"
}

variable "env" {
  description = "The environement (prod/dev/hml/test)"
}

variable "enable_autoscaling" {
  description = "If set to true, enable the autoscaling"
}

variable "asg_min_size" {
  description = "Minimum size of ASG"
}

variable "asg_max_size" {
  description = "Maximum size of ASG"
}

variable "instance_type" {
  description = "Instance type for ASG"
}

data "aws_availability_zones" "all" {}
