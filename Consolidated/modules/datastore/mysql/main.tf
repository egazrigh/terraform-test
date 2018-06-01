provider "aws" {
  region = "${var.region}"
}

resource "aws_db_instance" "mysqldb" {
  engine              = "mysql"
  allocated_storage   = 10
  instance_class      = "db.t2.micro"
  name                = "${var.cluster_name}_${var.env}"
  username            = "admin"
  password            = "${var.db_password}"
  skip_final_snapshot = true

  tags {
    Name = "${var.cluster_name}${var.env}database"
    Env  = "${var.env}"
  }
}
