locals {
  lambda_role_policy_arns = [
    "arn:aws:iam::aws:policy/SecretsManagerReadWrite",
    "arn:aws:iam::aws:policy/IAMReadOnlyAccess",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda" {
  count      = length(local.lambda_role_policy_arns)
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = local.lambda_role_policy_arns[count.index]
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda/access_key_rotate.py"
  output_path = "${path.module}/lambda/lambda_function_payload.zip"
}

resource "aws_lambda_permission" "allow_secrets_manager" {
  statement_id  = "AllowExecutionFromSecretsManager"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rotate_keys.function_name
  principal     = "secretsmanager.amazonaws.com"
  source_arn    = "arn:aws:secretsmanager:eu-west-1:294268556398:secret:mgn-MDneTK"
}

resource "aws_lambda_function" "rotate_keys" {
  filename      = "${path.module}/lambda/lambda_function_payload.zip"
  function_name = "access_key_rotate"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "access_key_rotate.lambda_handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.10"
}
