variable "aws_region" {
  description = "The AWS region to deploy infrastructure."
  type        = string
  default     = "us-east-1" # You can change this to your preferred region
}

variable "bucket_name" {
  description = "A unique name for the S3 bucket. You will be prompted for this."
  type        = string
}