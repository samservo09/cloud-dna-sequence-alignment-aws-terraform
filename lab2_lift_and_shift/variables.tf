# variables.tf

variable "s3_bucket_name" {
  description = "A globally unique name for your S3 bucket."
  type        = string
  # No default - Terraform will prompt you for this.
}

variable "key_pair_name" {
  description = "The name of your existing AWS EC2 Key Pair (for SSH access)."
  type        = string
  # No default - Terraform will prompt you for this.
}

variable "my_ip" {
  description = "Your local IP address (in CIDR format, e.g., '1.2.3.4/32'). Used to allow SSH access."
  type        = string
  # You can create a terraform.tfvars file to set this,
  # or provide it at the command line.
  # Example: terraform apply -var="my_ip=1.2.3.4/32"
}

variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "ec2_instance_type" {
  description = "The EC2 instance type to use."
  type        = string
  default     = "t3.micro" # Free Tier eligible
}