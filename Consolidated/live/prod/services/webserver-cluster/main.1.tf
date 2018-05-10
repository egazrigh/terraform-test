provider "aws" {
  region = "${var.region}"
}

module "webserver-cluster" {
  source                 = "../../../modules/services/webserver-cluster"
  cluster_name           = "${var.cluster_name}"
  db_remote_state_bucket = "eg2-s3bucket-for-shared-terraform-tfstate"
  db_remote_state_key    = "${var.env}/datastore/mysql/terraform.tfstate"
  region                 = "${var.region}"
  env                    = "${var.env}"
}

terraform {
  backend "s3" {
    # cannot use variable because of early initialization
    bucket = "eg2-s3bucket-for-shared-terraform-tfstate"
    key    = "prod/services/webserver-cluster/terraform.tfstate"
    region = "eu-west-3"
  }
}
