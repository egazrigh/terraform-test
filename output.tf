output "elb_dns_name" {
  description = "Show Elastic load balancer DNS name"
  value       = "${aws_elb.my-elb.dns_name}"
}
