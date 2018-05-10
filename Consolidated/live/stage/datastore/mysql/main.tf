provider "aws" {
  region = "eu-west-3"
}

terraform {
  backend "s3" {
    bucket = "eg2-s3bucket-for-shared-terraform-tfstate"
    key    = "stage/datastore/mysql/terraform.tfstate"
    region = "eu-west-3"
  }
}

resource "aws_db_instance" "mysqldb" {
  engine            = "mysql"
  allocated_storage = 10
  instance_class    = "db.t2.micro"
  name              = "mysqldb"
  username          = "admin"
  password          = "${var.db_password}"
}
