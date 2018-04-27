provider "aws" {
  region = "eu-west-3"
}

resource "aws_instance" "terraferic" {
  ami = "ami-0e55e373" #Ubuntu

  #ami = "ami-4f55e332" #Amazon Linux

  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]
  count                  = 1
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello World" > index.html
              nohup busybox httpd -f -p "${var.server_port}" &
              EOF
  tags {
    Name    = "TerrifEric One"
    Env     = "Test"
    Billing = "Someone Else"
  }
}

resource "aws_security_group" "instance" {
  name = "SG-terraform-example-instance"

  ingress {
    from_port   = "${var.server_port}"
    to_port     = "${var.server_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "server_port" {
  description = "The port the web server will use for http requests"
  type        = "string"
  default     = 8080
}

output "public_ip" {
  description = "Show public IP of the instance created"
  value       = "${aws_instance.terraferic.public_ip}"
}

output "security_group_name" {
  description = "Show security group name"
  value       = "${aws_security_group.instance.name}"
}
