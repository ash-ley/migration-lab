resource "aws_kms_key" "ebs" {
  description             = "This key is used to encrypt ebs volumes"
  enable_key_rotation     = true
  deletion_window_in_days = 10

  tags = {
    Name = "ebs-key"
  }
}
