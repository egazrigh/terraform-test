output "db-address" {
  value = "${aws_db_instance.mysqldb.address}"
}

output "db-port" {
  value = "${aws_db_instance.mysqldb.port}"
}
