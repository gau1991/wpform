resource "aws_vpc" "wp_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "dedicated"

  tags {
    Name = "WordPress_VPC"
  }
}

resource "aws_internet_gateway" "wp_igw" {
  vpc_id = "${aws_vpc.wp_vpc.id}"
}

resource "aws_nat_gateway" "wp_ngw_a" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.wp_public_subnet_a.id}"
  depends_on = ["aws_internet_gateway.wp_igw"]
}

resource "aws_nat_gateway" "wp_ngw_b" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.wp_public_subnet_b.id}"
  depends_on = ["aws_internet_gateway.wp_igw"]
}

resource "aws_route_table" "wp_public_route_table" {
  vpc_id = "${aws_vpc.wp_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.wp_igw.id}"
  }

  tags {
    Name = "WordPress Public Route Table"
  }
}

resource "aws_route_table" "wp_private_route_table_a" {
  vpc_id = "${aws_vpc.wp_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_internet_gateway.wp_ngw_a.id}"
  }

  tags {
    Name = "WordPress Private Route Table A"
  }
}

resource "aws_route_table" "wp_private_route_table_b" {
  vpc_id = "${aws_vpc.wp_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_internet_gateway.wp_ngw_b.id}"
  }

  tags {
    Name = "WordPress Private Route Table B"
  }
}

resource "aws_subnet" "wp_public_subnet_a" {
  vpc_id     = "${aws_vpc.wp_vpc.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "${var.az_a}"
  map_public_ip_on_launch = true

  tags {
    Name = "WordPress Public Subnet A"
  }
}

resource "aws_subnet" "wp_public_subnet_b" {
  vpc_id     = "${aws_vpc.wp_vpc.id}"
  cidr_block = "10.0.2.0/24"
  availability_zone = "${var.az_b}"
  map_public_ip_on_launch = true

  tags {
    Name = "WordPress Public Subnet B"
  }
}

resource "aws_subnet" "wp_private_subnet_a" {
  vpc_id     = "${aws_vpc.wp_vpc.id}"
  cidr_block = "10.0.3.0/24"
  availability_zone = "${var.az_a}"
  map_public_ip_on_launch = false

  tags {
    Name = "WordPress Private Subnet A"
  }
}

resource "aws_subnet" "wp_private_subnet_b" {
  vpc_id     = "${aws_vpc.wp_vpc.id}"
  cidr_block = "10.0.4.0/24"
  availability_zone = "${var.az_b}"
  map_public_ip_on_launch = false

  tags {
    Name = "WordPress Private Subnet B"
  }
}

resource "aws_subnet" "wp_db_subnet_a" {
  vpc_id     = "${aws_vpc.wp_vpc.id}"
  cidr_block = "10.0.5.0/24"
  availability_zone = "${var.az_a}"
  map_public_ip_on_launch = false

  tags {
    Name = "WordPress DB Subnet A"
  }
}

resource "aws_subnet" "wp_db_subnet_b" {
  vpc_id     = "${aws_vpc.wp_vpc.id}"
  cidr_block = "10.0.6.0/24"
  availability_zone = "${var.az_b}"
  map_public_ip_on_launch = false

  tags {
    Name = "WordPress DB Subnet B"
  }
}


resource "aws_route_table_association" "wp_public_subnet_association_a" {
  subnet_id      = "${aws_subnet.wp_public_subnet_a.id}"
  route_table_id = "${aws_route_table.wp_public_route_table.id}"
}

resource "aws_route_table_association" "wp_public_subnet_association_b" {
  subnet_id      = "${aws_subnet.wp_public_subnet_b.id}"
  route_table_id = "${aws_route_table.wp_public_route_table.id}"
}


resource "aws_route_table_association" "wp_private_subnet_association_a" {
  subnet_id      = "${aws_subnet.wp_private_subnet_a.id}"
  route_table_id = "${aws_route_table.wp_private_route_table_a.id}"
}

resource "aws_route_table_association" "wp_private_subnet_association_b" {
  subnet_id      = "${aws_subnet.wp_private_subnet_b.id}"
  route_table_id = "${aws_route_table.wp_private_route_table_b.id}"
}

resource "aws_route_table_association" "wp_db_subnet_association_a" {
  subnet_id      = "${aws_subnet.wp_db_subnet_a.id}"
  route_table_id = "${aws_route_table.wp_private_route_table_a.id}"
}

resource "aws_route_table_association" "wp_db_subnet_association_b" {
  subnet_id      = "${aws_subnet.wp_db_subnet_b.id}"
  route_table_id = "${aws_route_table.wp_private_route_table_b.id}"
}
