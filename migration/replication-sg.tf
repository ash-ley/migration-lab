resource "aws_security_group" "replication" {
  name        = "replication_sg"
  description = "Allow 443 inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "443 for replication"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "1500 for replication"
    from_port   = 1500
    to_port     = 1500
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
    Name = "replication_sg"
  }
}
