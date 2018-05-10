output "elb_dns_name" {
  description = "Show Elastic load balancer DNS name"
  value       = "${module.webserver-cluster.elb_dns_name}"
}
