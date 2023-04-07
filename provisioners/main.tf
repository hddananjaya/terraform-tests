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

resource "aws_key_pair" "web_keypair" {
  key_name   = "Web-KeyPair"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7ahsTsFj1PHlXObLbQbchyBBDp4ef/Y6cxUZ9OpcmHIAV8qbbjzER4x0Hn3wr50rGQu8sz64fni/glYDL8kLfLeaJ2rOkInfX3hXNmWlud0x0LEWIrXAU2PGDv2TD1bkz10mOotTVsH4cA7BhxBEnkYuK0M8UwvJXUTSCeYmtBTAtLoAgehgnk/HtWm+yEgp/qLtGdT1dsp+4Q9U81DQpj+6k5CtT9e6oe5iRxoJUVRpDc4fMDV14HZe6Taf8uWMd/tWW8SvMcaqMUtV/4/cbPR/0sqCcbmZjhe+evT+TiEtUsoDC4lsa3lSwzj2whM/otlBuEFYQyvdc49gsDoUS4MNpOz3QS3syFKo1918Nkd+y44IrpAaM0hcMkgF+skQakosCtz7CpGkC6qLapuiqj4T2HIHMBah++idRoKwxadu8jA6wgL42RZzeE3hm0YjUbBCsS1TxGdk3M7/RooQZ52npCY118491DoU5d5Znfk6NN/xMjZo38y7+3e+sL60= caretaker@pop-os"
}

data "cloudinit_config" "webserver" {
  gzip          = true
  base64_encode = true
  part {
    content_type = "text/cloud-config"
    content = file("./webserver.yaml")
  }
}

resource "aws_instance" "web" {
  ami           = "ami-06e46074ae430fba6"
  instance_type = "t3.micro"
  key_name = aws_key_pair.web_keypair.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  user_data = data.cloudinit_config.webserver.rendered

  provisioner "local-exec" {
    command = "echo hello >> ./private_ips.txt"
  }

  tags = {
    Name = "test-ec2-instance"
  }
}

# add a security group to allow port 22
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = "vpc-04bcaaa10419635fe"

  ingress {
    description      = "Allow SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Allow HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}
