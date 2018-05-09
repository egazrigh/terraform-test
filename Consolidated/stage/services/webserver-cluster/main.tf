provider "aws" {
  region = "eu-west-3"
}

terraform {
  backend "s3" {
    bucket = "eg2-s3bucket-for-shared-terraform-tfstate"
    key    = "stage/services/webserver-cluster/terraform.tfstate"
    region = "eu-west-3"
  }
}

resource "aws_autoscaling_group" "my-asg" {
  launch_configuration = "${aws_launch_configuration.my-launch-config.id}"

  availability_zones = ["${data.aws_availability_zones.all.names}"]

  load_balancers    = ["${aws_elb.my-elb.name}"]
  health_check_type = "ELB"

  min_size = 2
  max_size = 10

  tag {
    key                 = "Name"
    value               = "web-server-instance-deployed-by-terraform"
    propagate_at_launch = true
  }
}

resource "aws_elb" "my-elb" {
  name               = "elb-deployed-by-terraform"
  availability_zones = ["${data.aws_availability_zones.all.names}"]
  security_groups    = ["${aws_security_group.elb_sg.id}"]

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = "${var.server_port}"
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:${var.server_port}/"
  }
}

resource "aws_launch_configuration" "my-launch-config" {
  image_id = "ami-0e55e373" #Ubuntu

  instance_type = "t2.micro"

  #security_groups = ["${aws_security_group.servers-sg.id}", "${aws_security_group.servers-sg2.id}"]
  security_groups = ["${aws_security_group.servers-sg.id}"]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello World" > index.html
              nohup busybox httpd -f -p "${var.server_port}" &
              EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "servers-sg" {
  name = "servers_sg"

  ingress {
    from_port   = "${var.server_port}"
    to_port     = "${var.server_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "servers-sg2" {
  name = "servers_sg_dummy"

  ingress {
    from_port   = "81"
    to_port     = "81"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "elb_sg" {
  name = "elb_sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
