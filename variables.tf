variable "region" {
  type        = string
  description = "AWS region where resources are created"
}

variable "project_id" {
  type        = string
  description = "Project identifier used for naming and tagging"
}

variable "allowed_ip_range" {
  type        = list(string)
  description = "List of CIDR blocks allowed to access the infrastructure"
}

variable "vpc_id" {
  type        = string
  description = "ID of the existing VPC"
}

variable "public_subnet_id" {
  type        = string
  description = "ID of the existing public subnet"
}

variable "private_subnet_id" {
  type        = string
  description = "ID of the existing private subnet"
}

variable "public_instance_id" {
  type        = string
  description = "ID of the existing public EC2 instance"
}

variable "private_instance_id" {
  type        = string
  description = "ID of the existing private EC2 instance"
}