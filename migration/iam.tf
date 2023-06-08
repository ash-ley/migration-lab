locals {
  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]
}

resource "aws_iam_instance_profile" "this" {
  name = "ssm_profile"
  role = aws_iam_role.this.name
}

resource "aws_iam_role" "this" {
  name = "ssm_role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : {
      "Effect" : "Allow",
      "Principal" : { "Service" : "ec2.amazonaws.com" },
      "Action" : "sts:AssumeRole"
    }
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  count      = length(local.custom_role_policy_arns)
  role       = aws_iam_role.this.name
  policy_arn = local.custom_role_policy_arns[count.index]
}
