data "aws_ami" "my_aws_ami" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_instance" "db" {
  ami                    = data.aws_ami.my_aws_ami.id
  instance_type          = var.db_instance_type
  subnet_id              = module.vpc.private_subnets[0]
  user_data              = templatefile("${path.module}/templates/db_user_data.tftpl", { mysql_root_password = var.db_password, app_private_ip = var.app_private_ip })
  vpc_security_group_ids = [aws_security_group.db.id]

  tags = {
    Name = "DB-SERVER"
  }
}

resource "aws_instance" "app" {
  ami                    = data.aws_ami.my_aws_ami.id
  instance_type          = var.app_instance_type
  subnet_id              = module.vpc.public_subnets[0]
  user_data              = templatefile("${path.module}/templates/app_user_data.tftpl", { mysql_root_password = var.db_password, db_private_ip = aws_instance.db.private_ip })
  vpc_security_group_ids = [aws_security_group.app.id]

  tags = {
    Name = "APP-SERVER"
  }
}

resource "aws_network_interface" "app" {
  subnet_id       = module.vpc.public_subnets[0]
  private_ips     = [var.app_private_ip]
  security_groups = [aws_security_group.db.id]

  attachment {
    instance     = aws_instance.app.id
    device_index = 1
  }
}
