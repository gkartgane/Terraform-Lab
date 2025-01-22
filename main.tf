terraform {
  backend "s3" {
    bucket         = "terraform-shared-state-training-tuesday"
    key            = "prod/terraform.tfstate"
    region         = "ap-southeast-2"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

# 1. Create a VPC
resource "aws_vpc" "shared_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "SharedLabVPC"
  }
}

# 2. Create a Subnet (for simplicity, just one subnet)
resource "aws_subnet" "shared_subnet" {
  vpc_id                  = aws_vpc.shared_vpc.id
  cidr_block             = "10.0.1.0/24"
  availability_zone       = "ap-southeast-2b"
  map_public_ip_on_launch = true
  tags = {
    Name = "SharedLabSubnet"
  }
}

# 3. Create an Internet Gateway
resource "aws_internet_gateway" "shared_igw" {
  vpc_id = aws_vpc.shared_vpc.id
  tags = {
    Name = "SharedLabIGW"
  }
}

# 4. Create a Route Table & Route for Internet
resource "aws_route_table" "shared_rt" {
  vpc_id = aws_vpc.shared_vpc.id
  tags = {
    Name = "SharedLabRouteTable"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.shared_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.shared_igw.id
}

# Associate subnet with the route table
resource "aws_route_table_association" "shared_subnet_assoc" {
  subnet_id      = aws_subnet.shared_subnet.id
  route_table_id = aws_route_table.shared_rt.id
}

# 5. Security Group for SSH & HTTP
resource "aws_security_group" "shared_sg" {
  name        = "shared-lab-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.shared_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
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

  tags = {
    Name = "SharedLabSG"
  }
}

# 6. Create Multiple EC2 Instances
resource "aws_instance" "shared_ec2" {
  count                    = var.instance_count
  ami                      = "ami-0d11f9bfe33cfbe8b" # Amazon Linux 2023
  instance_type            = var.instance_type
  subnet_id                = aws_subnet.shared_subnet.id
  vpc_security_group_ids   = [aws_security_group.shared_sg.id]
  associate_public_ip_address = true
  key_name                 = var.ssh_key_name

  tags = {
    Name = "SharedInstance-${count.index}"
  }
}

