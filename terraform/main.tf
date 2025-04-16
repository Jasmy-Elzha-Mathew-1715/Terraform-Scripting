provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "main_subnet_1" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "main-subnet-1"
  }
}

resource "aws_subnet" "main_subnet_2" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "main-subnet-2"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "main-internet-gateway"
  }
}

resource "aws_security_group" "sg" {
  name        = "app-sg"
  description = "Security group for the application load balancer"
  vpc_id      = aws_vpc.main_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "app_lb" {
  name               = "app-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id]
  subnets            = [aws_subnet.main_subnet_1.id, aws_subnet.main_subnet_2.id]

  enable_cross_zone_load_balancing = true
  enable_http2                       = true

  tags = {
    Name = "app-load-balancer"
  }
}

resource "aws_lb_target_group" "app_tg" {
  name        = "app-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main_vpc.id
  target_type = "instance"
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

resource "aws_s3_bucket" "example" {
  bucket = "jasmy-tf-test-bucket-${random_id.bucket_id.hex}"

  tags = {
    Name        = "jasmy-tf-test-bucket"
    Environment = "Dev"
  }
}

resource "random_id" "bucket_id" {
  byte_length = 8
}

resource "random_id" "deployment_id" {
  byte_length = 4
}

resource "aws_instance" "example" {
  ami           = "ami-087f352c165340ea1"  
  instance_type = "t2.micro"               
  subnet_id     = aws_subnet.main_subnet_1.id 
  vpc_security_group_ids = [aws_security_group.sg.id] 

  associate_public_ip_address = true

  tags = {
    Name = "example-instance-${random_id.deployment_id.hex}"
  }
}

