output "elb_dns_name" {
  description = "Show Elastic load balancer DNS name"
  value       = "${aws_elb.my-elb.dns_name}"
}

output "elb_ID" {
  description = "Show Elastic load balancer ID"
  value       = "${aws_security_group.elb_sg.id}"
}
