data "template_file" "user_data_app" {
  template = file("${path.cwd}/templates/app_user_data.sh.tpl")
  vars = {
    mysql_root_password = var.db_password
    db_private_ip       = aws_instance.db.private_ip
  }
}

data "template_file" "user_data_db" {
  template = file("${path.cwd}/templates/db_user_data.sh.tpl")
  vars = {
    mysql_root_password = var.db_password
    app_private_ip      = var.app_private_ip
  }
}

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
  user_data              = data.template_file.user_data_db.rendered
  vpc_security_group_ids = [aws_security_group.db.id]

  tags = {
    Name = "DB-SERVER"
  }
}

resource "aws_instance" "app" {
  ami                    = data.aws_ami.my_aws_ami.id
  instance_type          = var.app_instance_type
  subnet_id              = module.vpc.public_subnets[0]
  user_data              = data.template_file.user_data_app.rendered
  vpc_security_group_ids = [aws_security_group.app.id]

  tags = {
    Name = "APP-SERVER"
  }
}

resource "aws_network_interface" "db" {
  subnet_id       = module.vpc.public_subnets[0]
  private_ips     = [var.app_private_ip]
  security_groups = [aws_security_group.db.id]

  attachment {
    instance     = aws_instance.app.id
    device_index = 0
  }
}
