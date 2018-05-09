variable "server_port" {
  description = "The port the web server will use for http requests"
  type        = "string"
  default     = 8080
}

data "aws_availability_zones" "all" {}
