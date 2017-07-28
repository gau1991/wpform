resource "aws_security_group" "wp_db_security_group" {
  name = "WordPress-RDS"

  description = "RDS for WordPRess"
  vpc_id = "${aws_vpc.wp_vpc.id}"

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "wp_db_subnet_group" {
  name       = "main"
  subnet_ids = ["${aws_subnet.wp_db_subnet_a.id}", "${aws_subnet.wp_db_subnet_b.id}"]

  tags {
    Name = "WordPress DB subnet group"
  }
}

resource "aws_db_instance" "wp_rds" {
  allocated_storage    = 10
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.6.35"
  instance_class       = "db.t2.small"
  name                 = "${var.db_name}"
  username             = "${var.db_username}"
  password             = "${var.db_password}"
  vpc_security_group_ids = ["${aws_security_group.wp_db_security_group.id}"]
  multi_az = true
  publicly_accessible = false
  db_subnet_group_name = "${aws_db_subnet_group.wp_db_subnet_group.name}"

  tags {
    Name        = "wp_database_server"
    Owner       = "${var.owner}"
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}
