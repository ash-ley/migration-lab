data "aws_ami" "my_aws_ami" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_instance" "db" {
  ami                    = data.aws_ami.my_aws_ami.id
  instance_type          = var.db_instance_type
  key_name               = "db"
  subnet_id              = module.vpc.private_subnets[0]
  user_data              = templatefile("${path.module}/templates/db_user_data.sh.tftpl", { mysql_root_password = var.db_password, app_private_ip = var.app_private_ip })
  vpc_security_group_ids = [aws_security_group.db.id]
  #checkov:skip=CKV_AWS_8:This db server is due to be replatformed so encryption not needed at this stage
  #checkov:skip=CKV_AWS_135:This db server is due to be replatformed so encryption not needed at this stage
  #checkov:skip=CKV_AWS_126:This db server is due to be replatformed so monitoring not needed at this stage

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name = "DB-SERVER"
  }
}

resource "aws_instance" "app" {
  provisioner "local-exec" {
    command = "sleep 30"
  }
  ami           = data.aws_ami.my_aws_ami.id
  instance_type = var.app_instance_type
  user_data     = templatefile("${path.module}/templates/app_user_data.sh.tftpl", { mysql_root_password = var.db_password, db_private_ip = aws_instance.db.private_ip })
  #checkov:skip=CKV_AWS_8:This app server is due to be rehosted so encryption not needed at this stage
  #checkov:skip=CKV_AWS_135:This app server is due to be rehosted so encryption not needed at this stage
  #checkov:skip=CKV_AWS_126:This app server is due to be rehosted so monitoring not needed at this stage

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.app.id
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name = "APP-SERVER"
  }
}

resource "aws_network_interface" "app" {
  subnet_id       = module.vpc.public_subnets[0]
  private_ips     = [var.app_private_ip]
  security_groups = [aws_security_group.app.id]
}
