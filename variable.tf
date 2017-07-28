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
