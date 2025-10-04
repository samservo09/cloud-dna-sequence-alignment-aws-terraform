# Lambda and API outputs
output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.dna_alignment.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.dna_alignment.arn
}

output "api_gateway_url" {
  description = "URL of the API Gateway"
  value       = aws_apigatewayv2_stage.api_stage.invoke_url
}

output "api_gateway_id" {
  description = "ID of the API Gateway"
  value       = aws_apigatewayv2_api.dna_api.id
}

# S3 bucket outputs
output "input_bucket_name" {
  description = "Name of the input S3 bucket"
  value       = aws_s3_bucket.input_bucket.bucket
}

output "output_bucket_name" {
  description = "Name of the output S3 bucket"
  value       = aws_s3_bucket.output_bucket.bucket
}

output "input_bucket_arn" {
  description = "ARN of the input S3 bucket"
  value       = aws_s3_bucket.input_bucket.arn
}

output "output_bucket_arn" {
  description = "ARN of the output S3 bucket"
  value       = aws_s3_bucket.output_bucket.arn
}

# Web interface
output "web_bucket_name" {
  description = "Name of the web hosting S3 bucket"
  value       = aws_s3_bucket.web_bucket.bucket
}

# CloudWatch logs
output "lambda_log_group_name" {
  description = "Name of the Lambda CloudWatch log group"
  value       = aws_cloudwatch_log_group.lambda_logs.name
}

output "api_log_group_name" {
  description = "Name of the API Gateway CloudWatch log group"
  value       = aws_cloudwatch_log_group.api_logs.name
}

# Usage instructions
output "usage_instructions" {
  description = "Instructions for using the DNA alignment service"
  value = <<-EOT
    🧬 DNA Sequence Alignment Service Deployed!
    
    📡 API Endpoint: ${aws_apigatewayv2_stage.api_stage.invoke_url}
    
    🔗 Available endpoints:
    - POST ${aws_apigatewayv2_stage.api_stage.invoke_url}/align
    - GET  ${aws_apigatewayv2_stage.api_stage.invoke_url}/health
    
    📁 S3 Buckets:
    - Input:  ${aws_s3_bucket.input_bucket.bucket}
    - Output: ${aws_s3_bucket.output_bucket.bucket}
    - Web:    ${aws_s3_bucket.web_bucket.bucket}
    
    🚀 To use:
    1. Upload FASTA files to: s3://${aws_s3_bucket.input_bucket.bucket}/
    2. Check results in: s3://${aws_s3_bucket.output_bucket.bucket}/results/
    3. Or use API directly with POST requests
    
    📊 Monitor logs:
    - Lambda: ${aws_cloudwatch_log_group.lambda_logs.name}
    - API:    ${aws_cloudwatch_log_group.api_logs.name}
  EOT
}
