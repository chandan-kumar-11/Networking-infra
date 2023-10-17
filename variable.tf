variable "region" {
  type    = string
  default = "us-west-2"
  # Update with your desired region
}
variable "instance_type" {
    default = "t2.micro"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"  # Update with appropriate CIDR block for your VPC
}

variable "public_subnet_cidr_block" {
  default = "10.0.1.0/24"  # Update with appropriate CIDR block for your public subnet
}

variable "private_subnet_cidr_block" {
  default = "10.0.2.0/24"  # Update with appropriate CIDR block for your private subnet
}

variable "creds" {}

variable "public_subnet_availability_zone" {
  default = "us-west-2a"  # Update with desired availability zone for public subnet
}

variable "private_subnet_availability_zone" {
  default = "us-west-2b"  # Update with desired availability zone for private subnet
}

