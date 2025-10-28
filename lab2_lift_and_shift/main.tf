# main.tf

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

# 1. Create the S3 bucket
resource "aws_s3_bucket" "results_bucket" {
  bucket = var.s3_bucket_name
}

# 2. Define the IAM Role for the EC2 instance
# This lets the EC2 instance assume a role
resource "aws_iam_role" "ec2_s3_role" {
  name = "lab2-ec2-s3-access-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# 3. Define the IAM Policy (what the role can do)
# Grants read/write access *only* to our new S3 bucket
resource "aws_iam_policy" "s3_access_policy" {
  name   = "lab2-s3-rw-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.results_bucket.arn}/*" # Access to objects
      },
      {
        Action   = "s3:ListBucket"
        Effect   = "Allow"
        Resource = aws_s3_bucket.results_bucket.arn # Access to the bucket itself
      }
    ]
  })
}

# 4. Attach the policy to the role
resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

# 5. Create an "instance profile" which is how EC2 uses the role
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "lab2-ec2-instance-profile"
  role = aws_iam_role.ec2_s3_role.name
}

# 6. Define the Security Group (virtual firewall)
resource "aws_security_group" "ec2_sg" {
  name        = "lab2-ec2-sg"
  description = "Allow SSH from my_ip and all outbound"

  # Allow SSH *only* from your IP address
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  # Allow all outbound traffic
  # (Needed for yum, pip, and talking to S3)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 7. Find the latest Ubuntu 22.04 LTS AMI in the specified region
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's owner ID

  filter {
    name   = "name"
    # Search for Ubuntu 22.04 LTS (Jammy), amd64, server, EBS-backed GP2 volume
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# 8. Create the EC2 Instance
resource "aws_instance" "alignment_server" {
  # ami           = data.aws_ami.amazon_linux_2.id # Comment out or delete this line
  ami           = data.aws_ami.ubuntu.id         # Use the Ubuntu AMI instead

  instance_type = var.ec2_instance_type
  key_name      = var.key_pair_name

  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  # Make sure this points to the new user_data.sh script below
  user_data = file("user_data.sh")

  tags = {
    Name = "Lab-2-Alignment-Server-Ubuntu" # Updated name tag
  }
}