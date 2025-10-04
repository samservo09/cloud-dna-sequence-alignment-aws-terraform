# Lambda function for DNA sequence alignment
resource "aws_lambda_function" "dna_alignment" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.project_name}-alignment-function"
  role            = aws_iam_role.lambda_role.arn
  handler         = "lambda_function.lambda_handler"
  runtime         = "python3.11"
  timeout         = 300  # 5 minutes
  memory_size     = 1024  # 1GB

  layers = [aws_lambda_layer_version.biopython_layer.arn]

  environment {
    variables = {
      INPUT_BUCKET  = aws_s3_bucket.input_bucket.bucket
      OUTPUT_BUCKET = aws_s3_bucket.output_bucket.bucket
      LOG_LEVEL     = "INFO"
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.lambda_logs,
  ]

  tags = local.common_tags
}

# Lambda layer for Biopython
resource "aws_lambda_layer_version" "biopython_layer" {
  filename         = "biopython_layer.zip"  # You'll need to create this
  layer_name       = "${var.project_name}-biopython-layer"
  description      = "Biopython and NumPy for DNA sequence analysis"
  
  compatible_runtimes = ["python3.11"]

  tags = local.common_tags
}

# Package Lambda function
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../src"
  output_path = "${path.module}/lambda_function.zip"
  excludes    = ["requirements.txt", "web_interface.html"]
}

# S3 bucket for input files
resource "aws_s3_bucket" "input_bucket" {
  bucket = "${var.project_name}-input-${random_id.bucket_suffix.hex}"

  tags = local.common_tags
}

# S3 bucket for output results
resource "aws_s3_bucket" "output_bucket" {
  bucket = "${var.project_name}-results-${random_id.bucket_suffix.hex}"

  tags = local.common_tags
}

# S3 bucket for web interface hosting
resource "aws_s3_bucket" "web_bucket" {
  bucket = "${var.project_name}-web-${random_id.bucket_suffix.hex}"

  tags = local.common_tags
}

# Random suffix for S3 bucket names
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# S3 bucket versioning
resource "aws_s3_bucket_versioning" "input_versioning" {
  bucket = aws_s3_bucket.input_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "output_versioning" {
  bucket = aws_s3_bucket.output_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket public access block
resource "aws_s3_bucket_public_access_block" "input_pab" {
  bucket = aws_s3_bucket.input_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "output_pab" {
  bucket = aws_s3_bucket.output_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "input_encryption" {
  bucket = aws_s3_bucket.input_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "output_encryption" {
  bucket = aws_s3_bucket.output_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 lifecycle policies
resource "aws_s3_bucket_lifecycle_configuration" "input_lifecycle" {
  bucket = aws_s3_bucket.input_bucket.id

  rule {
    id     = "delete_old_files"
    status = "Enabled"

    expiration {
      days = 30  # Delete files after 30 days
    }

    noncurrent_version_expiration {
      noncurrent_days = 7
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "output_lifecycle" {
  bucket = aws_s3_bucket.output_bucket.id

  rule {
    id     = "archive_old_results"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_INFREQUENT_ACCESS"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 365  # Delete after 1 year
    }
  }
}

# S3 bucket notification to trigger Lambda
resource "aws_s3_bucket_notification" "input_notification" {
  bucket = aws_s3_bucket.input_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.dna_alignment.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = ""
    filter_suffix       = ".fasta"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.dna_alignment.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = ""
    filter_suffix       = ".fa"
  }

  depends_on = [aws_lambda_permission.s3_invoke]
}

# Permission for S3 to invoke Lambda
resource "aws_lambda_permission" "s3_invoke" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dna_alignment.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.input_bucket.arn
}

# API Gateway for HTTP API
resource "aws_apigatewayv2_api" "dna_api" {
  name          = "${var.project_name}-api"
  protocol_type = "HTTP"
  description   = "API for DNA sequence alignment service"

  cors_configuration {
    allow_credentials = false
    allow_headers     = ["content-type", "x-amz-date", "authorization", "x-api-key"]
    allow_methods     = ["GET", "POST", "OPTIONS"]
    allow_origins     = ["*"]
    max_age          = 86400
  }

  tags = local.common_tags
}

# API Gateway stage
resource "aws_apigatewayv2_stage" "api_stage" {
  api_id      = aws_apigatewayv2_api.dna_api.id
  name        = var.environment
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_logs.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      routeKey       = "$context.routeKey"
      status         = "$context.status"
      protocol       = "$context.protocol"
      responseLength = "$context.responseLength"
    })
  }

  tags = local.common_tags
}

# API Gateway integration
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.dna_api.id
  integration_type = "AWS_PROXY"

  connection_type    = "INTERNET"
  description        = "Lambda integration for DNA alignment"
  integration_method = "POST"
  integration_uri    = aws_lambda_function.dna_alignment.invoke_arn
}

# API Gateway routes
resource "aws_apigatewayv2_route" "post_align" {
  api_id    = aws_apigatewayv2_api.dna_api.id
  route_key = "POST /align"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "get_health" {
  api_id    = aws_apigatewayv2_api.dna_api.id
  route_key = "GET /health"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Permission for API Gateway to invoke Lambda
resource "aws_lambda_permission" "api_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dna_alignment.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.dna_api.execution_arn}/*/*"
}

# CloudWatch log groups
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.project_name}-alignment-function"
  retention_in_days = 7

  tags = local.common_tags
}

resource "aws_cloudwatch_log_group" "api_logs" {
  name              = "/aws/apigateway/${var.project_name}-api"
  retention_in_days = 7

  tags = local.common_tags
}