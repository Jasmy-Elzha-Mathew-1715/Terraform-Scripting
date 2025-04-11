provider "aws" {
  region = "us-east-1"  # Adjust the region as necessary
}

resource "aws_instance" "example" {
  ami           = "ami-00a929b66ed6e0de6"  # Adjust for your region
  instance_type = "t2.micro"
}
