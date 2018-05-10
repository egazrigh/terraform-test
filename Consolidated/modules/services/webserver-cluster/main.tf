/*
terraform {
  backend "s3" {
    bucket = "eg2-s3bucket-for-shared-terraform-tfstate"
    key    = "stage/services/webserver-cluster/terraform.tfstate"
    region = "${var.region}"
  }
}
*/
data "terraform_remote_state" "db" {
  backend = "s3"

  config {
    bucket = "${var.db_remote_state_bucket}"
    key    = "${var.db_remote_state_key}"
    region = "${var.region}"
  }
}

resource "aws_autoscaling_group" "my-asg" {
  launch_configuration = "${aws_launch_configuration.my-launch-config.id}"

  availability_zones = ["${data.aws_availability_zones.all.names}"]

  load_balancers    = ["${aws_elb.my-elb.name}"]
  health_check_type = "ELB"

  min_size = 2
  max_size = 10

  tags {
    key                 = "Name"
    value               = "${var.cluster_name}-webserver-cluster"
    key                 = "Env"
    value               = "${var.env}"
    propagate_at_launch = true
  }
}

resource "aws_elb" "my-elb" {
  name               = "${var.cluster_name}-elb"
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

data "template_file" "user_data" {
  template = "${file("${path.module}/user-data.sh")}"

  vars {
    server_port = "${var.server_port}"
    db_address  = "${data.terraform_remote_state.db.db-address}"
    db_port     = "${data.terraform_remote_state.db.db-port}"
  }
}

resource "aws_launch_configuration" "my-launch-config" {
  image_id = "ami-0e55e373" #Ubuntu

  instance_type = "t2.micro"

  security_groups = ["${aws_security_group.servers-sg.id}"]

  user_data = "${data.template_file.user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "servers-sg" {
  name = "${var.cluster_name}-servers_sg"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "allow_server_port_in" {
  type              = "ingress"
  security_group_id = "${aws_security_group.servers-sg.id}"
  from_port         = "${var.server_port}"
  to_port           = "${var.server_port}"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group" "elb_sg" {
  name = "${var.cluster_name}-elb_sg"
}

resource "aws_security_group_rule" "allow_http_in_on_elb" {
  type              = "ingress"
  security_group_id = "${aws_security_group.elb_sg.id}"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_all_out_on_elb" {
  type              = "egress"
  security_group_id = "${aws_security_group.elb_sg.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
