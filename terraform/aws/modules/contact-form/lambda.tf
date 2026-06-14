data "archive_file" "lambda_zip_file" {
  type        = "zip"
  source_file = "${path.module}/lambdas/contact_form.py"
  output_path = "${path.module}/lambdas/contact_form.zip"
}

resource "aws_iam_role" "lambda_role" {
  name               = "devops_consulting_lambda_role"
  assume_role_policy = file("${path.module}/lambdas/lambda_assume_role_policy.json")
}

resource "aws_iam_role_policy_attachment" "lambda_exec_role_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "lambda_ses_send_email" {
  name        = "devops-consulting-lambda-ses-send-email"
  description = "Allow Lambda to send email via SES"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_ses_send_email_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_ses_send_email.arn
}

resource "aws_lambda_function" "contact_form_lambda_function" {
  function_name    = "devops_consulting_contact_form"
  role             = aws_iam_role.lambda_role.arn
  handler          = "contact_form.lambda_handler"
  runtime          = "python3.13"
  filename         = data.archive_file.lambda_zip_file.output_path
  timeout          = 30
  memory_size      = 128
  source_code_hash = data.archive_file.lambda_zip_file.output_base64sha256

  environment {
    variables = {
      CONFIG_SET           = ""
      SENDER_EMAIL         = var.sender_email
      SENDTO_EMAIL         = var.sendto_email
      DOMAIN_NAME          = var.domain_name
      EMAIL_SUBJECT_PREFIX = "[DevOps Consulting] "
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_exec_role_attachment,
    aws_iam_role_policy_attachment.lambda_ses_send_email_attachment
  ]
}
