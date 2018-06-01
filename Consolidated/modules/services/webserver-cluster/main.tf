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
  name                 = "${var.cluster_name}-${var.env}-asg"
  availability_zones   = ["${data.aws_availability_zones.all.names}"]

  load_balancers    = ["${aws_elb.my-elb.name}"]
  health_check_type = "ELB"

  min_size = "${var.asg_min_size}"
  max_size = "${var.asg_max_size}"

  /*
        tags {
          key                 = "Name"
          value               = "${var.cluster_name}-webserver-cluster"
          key                 = "Env"
          value               = "${var.env}"
          propagate_at_launch = true
        }
      */
  tags = [
    {
      key                 = "Name"
      value               = "${var.cluster_name}-webserver-cluster"
      propagate_at_launch = true
    },
    {
      key                 = "Env"
      value               = "${var.env}"
      propagate_at_launch = true
    },
  ]
}

resource "aws_elb" "my-elb" {
  name               = "${var.cluster_name}-${var.env}-elb"
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

  tags {
    Name = "${var.cluster_name}${var.env}"
    Env  = "${var.env}"
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
  image_id      = "ami-0e55e373"                      #Ubuntu
  name          = "${var.cluster_name}-${var.env}-lc"
  instance_type = "${var.instance_type}"

  security_groups = ["${aws_security_group.servers-sg.id}"]

  user_data = "${data.template_file.user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "servers-sg" {
  name = "${var.cluster_name}-${var.env}-servers_sg"

  tags {
    Name = "${var.cluster_name}-${var.env}-servers_sg"
    Env  = "${var.env}"
  }

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
  name = "${var.cluster_name}-${var.env}-elb_sg"

  tags {
    Name = "${var.cluster_name}-${var.env}-elb_sg"
    Env  = "${var.env}"
  }
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

resource "aws_autoscaling_schedule" "scale-out-during-business-hour" {
  count                  = "${var.enable_autoscaling}"
  scheduled_action_name  = "scale-out-during-business-hour"
  min_size               = "${var.asg_min_size}"
  max_size               = 10                                     # a variabiliser
  desired_capacity       = 5
  recurrence             = "0 9 * * *"
  autoscaling_group_name = "${aws_autoscaling_group.my-asg.name}"
}

resource "aws_autoscaling_schedule" "scale-in-at-night" {
  count                  = "${var.enable_autoscaling}"
  scheduled_action_name  = "scale-in-at-night"
  min_size               = "${var.asg_min_size}"
  max_size               = "${var.asg_max_size}"
  desired_capacity       = "${var.asg_min_size}"
  recurrence             = "0 17 * * *"
  autoscaling_group_name = "${aws_autoscaling_group.my-asg.name}"
}
