variable "aws_access_key" {
  description = "AWS Access Key"
}

variable "aws_secret_key" {
  description = "AWS Secret Key"
}

variable "region" {
  description = "AWS Region"
  default     = "us-west-2"
}

variable "az_a" {
  description = "AWS Region"
  default     = "us-west-2a"
}

variable "az_b" {
  description = "AWS Region"
  default     = "us-west-2b"
}

variable "db_username" {
  description = "Database User Name"
  default     = "root"
}

variable "db_password" {
  description = "Database Password"
}

variable "db_name" {
  description = "Database Name"
  default     = "wordpress"
}

variable "admin_email" {
  description = "Email ID for WordPress setup"
}

variable "admin_user" {
  description = "Admin user for WordPress setup"
  default = "admin"
}

variable "admin_password" {
  description = "Admin password for WordPress setup"
}

variable "site_title" {
  description = "Site Title for WordPress setup"
  default = "My WordPress site"
}

variable "owner" {
  description = "Value of owner tag to set"
}

variable "project" {
  description = "Value of project tag to set"
}

variable "environment" {
  description = "Value of environment tag to set"
}

variable "key_name" {
  description = "SSH Key Name for access"
}

variable "elb_outbound_ip" {
  description = "Outbound IP for ELB"
}

variable "bucket_name" {
  description = "S3 Bucket Name"
}
