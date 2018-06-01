output "db-address" {
  value = "${aws_db_instance.mysqldb.address}"
}

output "db-port" {
  value = "${aws_db_instance.mysqldb.port}"
}

output "db-id" {
  description = "Show database ID"
  value       = "${aws_db_instance.mysqldb.identifier}"
}
