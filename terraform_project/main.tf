provider "aws" {
  region = "us-east-1"
}

variable "region" {
  description = "AWS region for resources"
  default     = "us-east-1"
}

resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "my-todo-frontend-bucket"
}

resource "aws_s3_bucket_website_configuration" "frontend_website_config" {
  bucket = aws_s3_bucket.frontend_bucket.bucket
  index_document {
    suffix = "index.html"
  }
}

# EC2 instance for backend Node.js API
resource "aws_instance" "backend_instance" {
  ami           = "ami-001286816938a120d"  # Replace with a valid AMI ID for your region
  instance_type = "t4g.micro"  # Updated to t3.micro, which supports UEFI
  key_name      = "my-keypair"  # Replace with your SSH keypair name for access

  vpc_security_group_ids = [aws_security_group.sg.id]  # Attach security group by ID

  tags = {
    Name = "BackendInstance"
  }
}

# Security group for the EC2 instance
resource "aws_security_group" "sg" {
  name        = "backend-sg"
  description = "Allow inbound traffic to backend API (port 80)"
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Lambda function integration (optional)
resource "aws_lambda_function" "lambda" {
  filename      = "C:/Users/Dell/Desktop/cicd project/backend/lambda.zip"  # Ensure this points to your actual zip file
  function_name = "TodoLambda"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "index.handler"
  runtime       = "nodejs16.x"
}

# IAM Role for Lambda (optional)
resource "aws_iam_role" "lambda_exec" {
  name = "lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

# Outputs
output "frontend_bucket_url" {
  value = "http://${aws_s3_bucket.frontend_bucket.bucket}.s3-website-${var.region}.amazonaws.com"
}

output "backend_instance_public_ip" {
  value = aws_instance.backend_instance.public_ip
}
