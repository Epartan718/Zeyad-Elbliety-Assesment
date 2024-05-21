# Automate message exchange between servers using Terraform, SQS, SNS, and Python
#Provider configuration
provider "aws" {
    region = "us-east-1"
}

#Variable Definition
variable "ami_id" {
  description = "AMI ID for the EC2 Instances"
  type        = string
  default     = "ami-0bb84b8ffd87024d8"
}

variable "instance_type" {
  description = "type of EC2 Instance"
  type        = string
  default     = "t2.micro"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
variable "s3_bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "Assessment-bucket"
}


#SNS 
resource "aws_sns_topic" "example_topic" {
  name = "example-topic"
}

#SQS
resource "aws_sqs_queue" "example_queue" {
  name = "example-queue"
}

#SNS Topic Subscription
resource "aws_sns_topic_subscription" "example_subscription" {
  topic_arn = "aws_sns_topic.example_topic.arn"
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.example_queue.arn
}

#Security Group
resource "aws_security_group" "instance_sg" {
  name        = "instance_sg"
  description = "Allow SSH and HTTP traffic"

  ingress {
    from_port    = 22
    to_port      = 22
    protocol     = "tcp"
    cidr_blocks  =["0.0.0.0/0"]
 }


 ingress {
    from_port    = 80
    to_port      = 80
    protocol     = "tcp"
    cidr_blocks  =["0.0.0.0/0"]
 }

 egress {
    from_port    = 0
    to_port      = 0
    protocol     = "-1"
    cidr_blocks  =["0.0.0.0/0"]
 }
}
# IAM Role and Policy for EC2
resource "aws_iam_role" "ec2_role" {
  name = "ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "ec2_policy" {
  name        = "ec2_policy"
  description = "Policy for EC2 to interact with SNS, SQS, and S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sns:Publish",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "s3:PutObject"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_attach_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_policy.arn
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_role.name
}


#EC2 Instances
resource "aws_instance" "server" {
  count           = 2
  ami             = var.ami_id
  instance_type   = var.instance_type
  security_groups = [aws_security_group.instance_sg.name]
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  tags = {
    Name = "Server${count.index + 1}"
 }

  user_data = <<-EOF
      #!/bin/bash
      yum update -y
      yum install -y python3
      pip3 install boto3
      EOF
}
#S3 Bucket
resource "aws_s3_bucket" "log_bucket" {
  bucket = var.s3_bucket_name
}

#Output Values
  output "server_a_public_ip" {
    value       = aws_instance.server[0].public_ip
    description = "Public Ip Address of Server A"
}
 output "server_b_public_ip" {
    value       = aws_instance.server[1].public_ip
    description = "Public Ip Address of Server B"
