resource "aws_lambda_function" "gef_dirlist" {
  function_name    = "gef-org-uk-dirList-${var.environment}"
  handler          = "dir_list.handler"
  source_code_hash = data.archive_file.gef_dirlist.output_base64sha256
  runtime          = "python3.12"
  role             = aws_iam_role.gef_lambda_iam.arn
  filename         = "gef_lambda_dirlist_payload.zip"
  environment {
    variables = {
      BUCKET_NAME  = module.gef_org_uk.bucket_id
    }
  }
}


data "archive_file" "gef_dirlist" {
  type        = "zip"
  source_file = "lambda/dir_list.py"
  output_path = "gef_lambda_dirlist_payload.zip"
}


resource "aws_lambda_function_url" "gef_dirlist" {
  function_name      = aws_lambda_function.gef_dirlist.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["*"]
    allow_headers     = ["date", "keep-alive"]
    expose_headers    = ["keep-alive", "date"]
    max_age           = 86400
  }
}

output "dirList_api" {
    value = aws_lambda_function_url.gef_dirlist.function_url
}

resource "aws_iam_role" "gef_lambda_iam" {
  name = "gef-org-uk-dirList-${var.environment}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "gef_role_policy" {
  name = "gef-org-uk-dirList"
  role = aws_iam_role.gef_lambda_iam.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": "${module.gef_org_uk.bucket_arn}"
    }
  ]
}
EOF
}
