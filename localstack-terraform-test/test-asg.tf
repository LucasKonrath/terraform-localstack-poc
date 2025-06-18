# Simple test for Auto Scaling Group in LocalStack
# This file can be used to test ASG functionality separately

resource "aws_vpc" "test_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "test-vpc"
  }
}

resource "aws_subnet" "test_subnet" {
  vpc_id                  = aws_vpc.test_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "test-subnet"
  }
}

resource "aws_security_group" "test_sg" {
  name_prefix = "test-sg-"
  vpc_id      = aws_vpc.test_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "test-security-group"
  }
}

resource "aws_launch_template" "test_template" {
  name_prefix   = "test-template-"
  image_id      = "ami-12345678"
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.test_sg.id]

  tags = {
    Name = "test-launch-template"
  }
}

resource "aws_autoscaling_group" "test_asg" {
  name                = "test-asg"
  vpc_zone_identifier = [aws_subnet.test_subnet.id]
  min_size            = 1
  max_size            = 2
  desired_capacity    = 1

  launch_template {
    id      = aws_launch_template.test_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "test-asg-instance"
    propagate_at_launch = true
  }
}

output "test_asg_arn" {
  value = aws_autoscaling_group.test_asg.arn
}
