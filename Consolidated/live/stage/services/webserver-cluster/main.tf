provider "aws" {
  region = "${var.region}"
}

module "webserver-cluster" {
  source                 = "git@github.com:egazrigh/terraform-modules.git//services/webserver-cluster?ref=v0.0.1"
  cluster_name           = "${var.cluster_name}"
  db_remote_state_bucket = "eg2-s3bucket-for-shared-terraform-tfstate"
  db_remote_state_key    = "${var.env}/datastore/mysql/terraform.tfstate"
  region                 = "${var.region}"
  env                    = "${var.env}"
}

#Add/overload a security group rule to ELB in this environnement
resource "aws_security_group_rule" "allow_testing_in" {
  type              = "ingress"
  security_group_id = "${module.webserver-cluster.elb_ID}"
  from_port         = 12345
  to_port           = 12345
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

terraform {
  backend "s3" {
    # cannot use variable because of early initialization
    bucket = "eg2-s3bucket-for-shared-terraform-tfstate"
    key    = "stage/services/webserver-cluster/terraform.tfstate"
    region = "eu-west-3"
  }
}
