locals {
  db_ports  = [22, 3306]
  app_ports = [22, 80]
}
resource "aws_security_group" "db" {
  name        = "db_sg"
  description = "Allow SSH and MYSQL inbound traffic"
  vpc_id      = module.vpc.vpc_id

  dynamic "ingress" {
    for_each = local.db_ports
    content {
      description     = "app to db"
      from_port       = ingress.value
      to_port         = ingress.value
      protocol        = "tcp"
      security_groups = [aws_security_group.app.id]
    }
  }

  egress {
    description      = "Outbound open"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_db_ssh_mysql"
  }
}

resource "aws_security_group" "app" {
  name        = "app_sg"
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id      = module.vpc.vpc_id

  dynamic "ingress" {
    for_each = local.app_ports
    content {
      description = "app ingress"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]

    }
  }

  egress {
    description      = "Outbound open"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_app_ssh_http"
  }
}
