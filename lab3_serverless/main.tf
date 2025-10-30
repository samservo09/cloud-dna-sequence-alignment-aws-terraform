terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# 1. S3 BUCKET FOR INPUT/OUTPUT
resource "aws_s3_bucket" "dna_bucket" {
  # Use the variable to set the name, and add a random suffix for uniqueness
  bucket = "${var.bucket_name}-dna-storage"
}

# Create the "input/" folder object as required by the README
resource "aws_s3_object" "input_folder" {
  bucket = aws_s3_bucket.dna_bucket.id
  key    = "input/"
}

# 2. DYNAMODB TABLE FOR METADATA
resource "aws_dynamodb_table" "alignment_jobs" {
  name           = "dna-alignment-jobs" # As specified in the README
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "filename" # Use the filename as the primary key

  attribute {
    name = "filename"
    type = "S"
  }
}

# 3. IAM ROLE FOR LAMBDA
# This role allows Lambda to be "assumed" (used) by the Lambda service
resource "aws_iam_role" "lambda_exec_role" {
  name = "dna_lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# This policy defines what the Lambda function can DO
resource "aws_iam_role_policy" "lambda_policy" {
  name = "dna_lambda_policy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        # Allow reading/writing from the S3 bucket
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ],
        Effect   = "Allow",
        Resource = "${aws_s3_bucket.dna_bucket.arn}/*" # Access to all objects
      },
      {
        # Allow writing job status to DynamoDB
        Action = [
          "dynamodb:PutItem"
        ],
        Effect   = "Allow",
        Resource = aws_dynamodb_table.alignment_jobs.arn
      },
      {
        # Allow creating logs
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# 4. LAMBDA FUNCTION
resource "aws_lambda_function" "dna_align_lambda" {
  filename         = "lambda_package.zip" # The zip file you created
  function_name    = "dna-alignment-processor"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "lambda_handler.handler" # Assumes python file is lambda_handler.py and function is handler
  source_code_hash = filebase64sha256("lambda_package.zip")
  runtime          = "python3.9" # Match the runtime you built the package for
  timeout          = 300       # 5 minutes
}

# 5. S3 TRIGGER FOR LAMBDA
# This gives S3 permission to trigger the Lambda
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dna_align_lambda.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.dna_bucket.arn
}

# This sets up the notification on the bucket
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.dna_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.dna_align_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "input/" # Only trigger for files in the input/ folder
  }

  depends_on = [aws_lambda_permission.allow_s3]
}