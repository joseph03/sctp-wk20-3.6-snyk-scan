provider "aws" {
  region = var.aws_region # instead of "us-east-1" to clear var not use warning
}

terraform {
  #add to clear missing terraform version warning
  required_version = ">= 1.5.0"

  #add to clear mssing aws version warning
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "hello_world" {
  function_name = "hello-world-function"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "hello_world.lambda_handler"
  runtime       = "python3.12"
  filename      = "${path.module}/lambda/hello_world.zip"

  source_code_hash = filebase64sha256("${path.module}/lambda/hello_world.zip")
}
