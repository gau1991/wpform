variable "aws_access_key" {
  description = "AWS Access Key"
}

variable "aws_secret_key" {
  description = "AWS Secret Key"
}

variable "region" {
  description = "AWS Region"
  default     = "us-east-1"
}

variable "az_a" {
  description = "AWS Region"
  default     = "us-east-1a"
}

variable "az_b" {
  description = "AWS Region"
  default     = "us-east-1b"
}

variable "db_name" {
  description = "Database Name"
  default     = "wordpress"
}

variable "db_username" {
  description = "Database User Name"
  default     = "root"
}

variable "db_password" {
  description = "Database Password"
  default     = "root123"
}

variable "db_name" {
  description = "Database Name"
  default     = "wordpress"
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
}

variable "admin_password" {
  description = "Admin password for WordPress setup"
}

variable "site_title" {
  description = "Site Title for WordPress setup"
}

variable "dns_name" {
  description = "DNS Name for WordPress setup"
}

variable "owner" {
  description = "Value of owner tag to set"
}

variable "key_name" {
  description = "SSH Key Name for access"
}
