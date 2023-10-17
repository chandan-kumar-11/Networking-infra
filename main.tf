provider "aws" {
  region = var.region
  # shared__credentials_file = var.creds
  profile = "default"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      # region = var.region
      version = "~> 3.0"
    }
  }
}  

# variable "region" {
#   description = "AWS region"
# }

# variable "vpc_cidr_block" {
#   description = "CIDR block for the VPC"
# }

# variable "public_subnet_cidr_block" {
#   description = "CIDR block for the public subnet"
# }

# variable "private_subnet_cidr_block" {
#   description = "CIDR block for the private subnet"
# }



resource "aws_vpc" "application_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "app-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.application_vpc.id

  tags = {
    Name = "app-igw"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.application_vpc.id
  cidr_block              = var.public_subnet_cidr_block
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.application_vpc.id
  cidr_block              = var.private_subnet_cidr_block
  availability_zone       = "us-west-2b"

  tags = {
    Name = "private-subnet"
  }
}

# Create a public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.application_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}
# Associate the public route table with the public subnet
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Create a private route table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.application_vpc.id

  tags = {
    Name = "private-route-table"
  }
}

# Associate the private route table with the private subnet
resource "aws_route_table_association" "private_association" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}



/* Elastic IP for NAT */
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
}

/* NAT */
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public.*.id, 0)
  depends_on    = [aws_internet_gateway.igw]

  tags = {
    Name = "nat-gw"
  }
}

resource "aws_s3_bucket" "example_bucket" {
  bucket = "grafana-json-collector"
  
}



# terraform {
#   backend "s3" {
#     bucket         = "grafana-json-collector"  # Replace with your S3 bucket name
#     key            = "."
#     region         = "us-west-2"  # Replace with your desired AWS region
#     dynamodb_table = "terraform-lock"  # Replace with your DynamoDB table name for locking
#   }
# }