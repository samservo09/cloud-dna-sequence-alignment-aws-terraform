# outputs.tf

output "s3_bucket_name" {
  description = "The name of the S3 bucket created for results."
  value       = aws_s3_bucket.results_bucket.bucket
}

output "instance_public_ip" {
  description = "The public IP address of the EC2 alignment server. Use this to SSH."
  value       = aws_instance.alignment_server.public_ip
}

output "ssh_command" {
  description = "Example command to SSH into your instance."
  value       = "ssh -i \"YOUR-KEY-NAME.pem\" ec2-user@${aws_instance.alignment_server.public_ip}"
}