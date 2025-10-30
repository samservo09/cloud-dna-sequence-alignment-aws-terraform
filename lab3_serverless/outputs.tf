output "s3_bucket_name" {
  description = "The name of the S3 bucket created."
  value       = aws_s3_bucket.dna_bucket.bucket
}

output "dynamodb_table_name" {
  description = "The name of the DynamoDB table for job metadata."
  value       = aws_dynamodb_table.alignment_jobs.name
}

output "lambda_function_name" {
  description = "The name of the Lambda function."
  value       = aws_lambda_function.dna_align_lambda.function_name
}