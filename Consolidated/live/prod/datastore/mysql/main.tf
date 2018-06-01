provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "eg2-s3bucket-for-shared-terraform-tfstate"
    key    = "prod/datastore/mysql/terraform.tfstate"
    region = "eu-west-3"
  }
}

module "mysqldb" {
  source       = "../../../../modules/datastore/mysql"
  cluster_name = "${var.cluster_name}"
  region       = "${var.region}"
  env          = "${var.env}"
  db_password  = "${var.db_password}"
}
