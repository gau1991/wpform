data "template_file" "user_data" {
  template = "${file("user_data.tpl")}"

  vars {
    db_name = "${var.db_name}"
    db_username = "${var.db_username}"
    db_password = "${var.db_password}"
    db_host = "${aws_db_instance.wp_rds.endpoint}"
    site_url = "${aws_elb.wp_elb.dns_name}"
    site_title = "${var.site_title}"
    site_admin_name = "${var.admin_user}"
    site_admin_password = "${var.admin_password}"
    site_admin_email = "${var.admin_email}"
  }
}

resource "aws_security_group" "wp_instance_security_group" {
  name        = "WordPress Security Group"
  description = "WordPress Security Group"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  vpc_id = "${aws_vpc.wp_vpc.id}"

}

resource "aws_launch_configuration" "wp_launch_configuration" {
  name_prefix   = "wp-instance-"
  image_id      = "ami-6df1e514"
  instance_type = "t2.medium"
  key_name = "${var.key_name}"
  security_groups = ["${aws_security_group.wp_instance_security_group.id}"]
  associate_public_ip_address = false
  user_data = "${data.template_file.user_data.rendered}"

  root_block_device {
    volume_size = "50"
    volume_type = "gp2"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "wp_autoscaling_group" {
  name                      = "WordPress Autoscaling Group"
  max_size                  = 5
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = 1
  force_delete              = true
  launch_configuration      = "${aws_launch_configuration.wp_launch_configuration.name}"
  min_elb_capacity          = 1
  vpc_zone_identifier       = ["${aws_subnet.wp_private_subnet_a.id}", "${aws_subnet.wp_private_subnet_b.id}"]

  tag {
    key                 = "Owner"
    value               = "${var.owner}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "${var.environment}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = "${var.project}"
    propagate_at_launch = true
  }

}

resource "aws_autoscaling_policy" "wp_scale_up" {
    name = "scale-up"
    scaling_adjustment = 1
    adjustment_type = "ChangeInCapacity"
    cooldown = 300
    autoscaling_group_name = "${aws_autoscaling_group.wp_autoscaling_group.name}"
}

resource "aws_autoscaling_policy" "wp_scale_down" {
    name = "scale-down"
    scaling_adjustment = -1
    adjustment_type = "ChangeInCapacity"
    cooldown = 300
    autoscaling_group_name = "${aws_autoscaling_group.wp_autoscaling_group.name}"
}

resource "aws_cloudwatch_metric_alarm" "wp_memory_high" {
    alarm_name = "mem-util-high"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "MemoryUtilization"
    namespace = "System/Linux"
    period = "300"
    statistic = "Average"
    threshold = "60"
    alarm_description = "This metric monitors ec2 memory for high utilization on WordPress hosts"
    alarm_actions = [
        "${aws_autoscaling_policy.wp_scale_up.arn}"
    ]
    dimensions {
        AutoScalingGroupName = "${aws_autoscaling_group.wp_autoscaling_group.name}"
    }
}

resource "aws_cloudwatch_metric_alarm" "wp_memory_low" {
    alarm_name = "mem-util-low"
    comparison_operator = "LessThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "MemoryUtilization"
    namespace = "System/Linux"
    period = "300"
    statistic = "Average"
    threshold = "40"
    alarm_description = "This metric monitors ec2 memory for low utilization on WordPress hosts"
    alarm_actions = [
        "${aws_autoscaling_policy.wp_scale_up.arn}"
    ]
    dimensions {
        AutoScalingGroupName = "${aws_autoscaling_group.wp_autoscaling_group.name}"
    }
}

resource "aws_security_group" "wp_elb_security_group" {
  name        = "WordPress ELB Security Group"
  description = "WordPress ELB  Group"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16", "${var.elb_outbound_ip}"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16", "${var.elb_outbound_ip}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  vpc_id = "${aws_vpc.wp_vpc.id}"
}

resource "aws_elb" "wp_elb" {
  name               = "wp-elb"
  subnets            = ["${aws_subnet.wp_public_subnet_a.id}", "${aws_subnet.wp_public_subnet_b.id}"]
  security_groups    = ["${aws_security_group.wp_elb_security_group.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 500

  tags {
    Name        = "wp_database_server"
    Owner       = "${var.owner}"
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}

resource "aws_lb_cookie_stickiness_policy" "wp_lb_stickiness" {
  name                     = "wp-stickness-policy"
  load_balancer            = "${aws_elb.wp_elb.id}"
  lb_port                  = 80
  cookie_expiration_period = 3600
}
