provider "aws" {
  profile = "myDonut"
  region  = "us-west-1"
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
      },
    ],
  })
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    actions = [
      "lambda:*",
      "apigateway:*",
      "iam:PassRole",
      "s3:*",
      "cloudformation:*",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "lambda_policy" {
  role   = aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.lambda_policy.json
}

resource "aws_iam_policy" "s3_cloudformation_policy" {
  name        = "S3CloudFormationFullAccess"
  description = "Policy that grants full access to S3 and CloudFormation resources"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "cloudformation:*",
          "s3:*",
          "lambda:*",
          "logs:*"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "attach_s3_cloudformation" {
  user       = "donut_user_1"
  policy_arn = aws_iam_policy.s3_cloudformation_policy.arn
}


resource "aws_s3_bucket" "serverless_deployment_bucket" {
  bucket = "serverless-nestjs-lambda-deployment-bucket"
}