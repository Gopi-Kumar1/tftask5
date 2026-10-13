locals {
  common_tags = {
    Project = var.project_id
  }
}

resource "aws_security_group" "ssh" {
  name        = "${var.project_id}-ssh-sg"
  description = "Allow SSH and ICMP from allowed IP ranges"
  vpc_id      = var.vpc_id
  tags        = merge(local.common_tags, { Name = "${var.project_id}-ssh-sg" })
}

resource "aws_security_group" "public_http" {
  name        = "${var.project_id}-public-http-sg"
  description = "Allow HTTP and ICMP from allowed IP ranges"
  vpc_id      = var.vpc_id
  tags        = merge(local.common_tags, { Name = "${var.project_id}-public-http-sg" })
}

resource "aws_security_group" "private_http" {
  name        = "${var.project_id}-private-http-sg"
  description = "Allow 8080 and ICMP from the public HTTP SG only"
  vpc_id      = var.vpc_id
  tags        = merge(local.common_tags, { Name = "${var.project_id}-private-http-sg" })
}

resource "aws_security_group_rule" "ssh_ingress_ssh" {
  type              = "ingress"
  security_group_id = aws_security_group.ssh.id
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = var.allowed_ip_range
  description       = "SSH from allowed IPs"
}

resource "aws_security_group_rule" "ssh_ingress_icmp" {
  type              = "ingress"
  security_group_id = aws_security_group.ssh.id
  protocol          = "icmp"
  from_port         = -1
  to_port           = -1
  cidr_blocks       = var.allowed_ip_range
  description       = "ICMP from allowed IPs"
}

resource "aws_security_group_rule" "public_http_ingress_http" {
  type              = "ingress"
  security_group_id = aws_security_group.public_http.id
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = var.allowed_ip_range
  description       = "HTTP from allowed IPs"
}

resource "aws_security_group_rule" "public_http_ingress_icmp" {
  type              = "ingress"
  security_group_id = aws_security_group.public_http.id
  protocol          = "icmp"
  from_port         = -1
  to_port           = -1
  cidr_blocks       = var.allowed_ip_range
  description       = "ICMP from allowed IPs"
}

resource "aws_security_group_rule" "private_http_ingress_http" {
  type                     = "ingress"
  security_group_id        = aws_security_group.private_http.id
  protocol                 = "tcp"
  from_port                = 8080
  to_port                  = 8080
  source_security_group_id = aws_security_group.public_http.id
  description              = "8080 from public HTTP SG"
}

resource "aws_security_group_rule" "private_http_ingress_icmp" {
  type                     = "ingress"
  security_group_id        = aws_security_group.private_http.id
  protocol                 = "icmp"
  from_port                = -1
  to_port                  = -1
  source_security_group_id = aws_security_group.public_http.id
  description              = "ICMP from public HTTP SG"
}

data "aws_instance" "public" {
  instance_id = var.public_instance_id
}

data "aws_instance" "private" {
  instance_id = var.private_instance_id
}

# Public instance: SSH SG + Public HTTP SG
resource "aws_network_interface_sg_attachment" "public_ssh" {
  security_group_id    = aws_security_group.ssh.id
  network_interface_id = data.aws_instance.public.network_interface_id
}

resource "aws_network_interface_sg_attachment" "public_http" {
  security_group_id    = aws_security_group.public_http.id
  network_interface_id = data.aws_instance.public.network_interface_id
}

# Private instance: SSH SG + Private HTTP SG
resource "aws_network_interface_sg_attachment" "private_ssh" {
  security_group_id    = aws_security_group.ssh.id
  network_interface_id = data.aws_instance.private.network_interface_id
}

resource "aws_network_interface_sg_attachment" "private_http" {
  security_group_id    = aws_security_group.private_http.id
  network_interface_id = data.aws_instance.private.network_interface_id
}