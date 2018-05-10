output "db-address" {
  value = "${module.mysqldb.db-address}"
}

output "db-port" {
  value = "${module.mysqldb.db-port}"
}

output "db-id" {
  description = "Show database ID"
  value       = "${module.mysqldb.db-id}"
}
