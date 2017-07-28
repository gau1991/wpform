data "template_file" "user_data" {
  template = "${file("user_data.tpl")}"

  vars {
    db_name = "${var.db_name}"
    db_username = "${var.db_username}"
    db_password = "${var.db_password}"
    db_host = "${aws_db_instance.wp_rds.endpoint}"
    site_url = "${var.dns_name}"
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
  name = "WordPress Launch Configuration"
  name_prefix   = "wp-instance-"
  image_id      = "ami-a4c7edb2"
  instance_type = "t2.medium"
  key_name = "${var.key_name}"
  security_groups = ["${aws_security_group.wp_instance_security_group}"]
  associate_public_ip_address = false
  user_data = "${data.template_file.user_data.rendered}"

  root_block_device {
    volume_size = "50G"
    volume_type = "gp2"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "wp_autoscaling_group" {
  availability_zones        = ["${var.az_a}", "${var.az_b}"]
  name                      = "WordPress Autoscaling Group"
  max_size                  = 5
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = 1
  force_delete              = true
  launch_configuration      = "${aws_launch_configuration.wp_launch_configuration.name}"
  min_elb_capacity          = 1

  tag {
    key                 = "owner"
    value               = "${var.owner}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "${var.environment}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Product"
    value               = "${var.product}"
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
