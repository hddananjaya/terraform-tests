terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "web" {
  ami           = "ami-06e46074ae430fba6"
  instance_type = "t3.micro"

  tags = {
    Name = "test-ec2-instance"
  }
}
