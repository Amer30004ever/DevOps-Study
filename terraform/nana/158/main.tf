provider "aws" { #aws user needs necessary permissions
  region = "eu-west-3" #remove it if it is set in config file
  access_key = "" #remove it if it is set in config file
  secret_key = "" #remove it if it is set in config file
}

resource "aws_vpc" "dev-vpc-1" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Amer-vpc-1"
  }
}

resource "aws_subnet" "dev-subnet-1" {
  vpc_id = aws_vpc.dev-vpc-1.id
  cidr_block = "10.0.10.0/24"
  availability_zone = "eu-west-3a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Amer-subnet-1"
  }
}

output "dev-vpc-id" {
  value = aws_vpc.dev-vpc-1.id
}

#dev-vpc-id = "vpc-0008061edcfca1eb4" <-----
output "dev-subnet-id" {
  value = aws_subnet.dev-subnet-1.id
}

#dev-subnet-id = "subnet-06710709757b98e1d" <-----

#--------------------------------------------------

data "aws_vpc" "existing-vpc" {
  default = true
}

resource "aws_subnet" "dev-subnet-2" {
  vpc_id = data.aws_vpc.existing-vpc.id
  cidr_block = "172.31.48.0/20"
  availability_zone = "eu-west-3a"
  tags = {
    Name = "Amer-subnet-2"
  }
}

#--------------------------------------------
variable "vpc_cidr_block" {
  description = "vpc cidr block"
}

variable "subnet_cidr_block" {
  description = "subnet cidr block"
  #default = "10.0.10.0/24" #A default value makes the variable is optional
  type = string #type : specifies what value types are accepted
}
variable "environment" {
  description = "deployment environment"
}
resource "aws_vpc" "dev-vpc-3" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "var.environment"  #to Replicate same infrastructure for different environments
  }

}
resource "aws_subnet" "dev-subnet-3" {
  vpc_id = aws_vpc.dev-vpc-3.id
  cidr_block = var.subnet_cidr_block
  availability_zone = "eu-west-3a"
  tags = {
    Name = "Amer-subnet-3"
  }
}
#.\terraform.exe plan
#var.subnet_cidr_block
#  subnet cidr block
#  Enter a value:
### OR directly with command
#.\terraform.exe apply -var "subnet_cidr_block=10.0.30.0/24"
#.\terraform.exe apply -var-file terraform-dev.tfvars
###
#with variable file
#--------------------------------------------

variable "cidr_blocks_1"  {
  description = "cidr blocks for vpc and subnet"
  type = list(string)
}

resource "aws_vpc" "dev-vpc-4" {
  cidr_block = var.cidr_blocks_1[0]
  tags = {
    Name = "dev-vpc-4"
  }
}

resource "aws_subnet" "dev-subnet-4" {
  vpc_id = aws_vpc.dev-vpc-4.id
  cidr_block = var.cidr_blocks_1[1] 
  availability_zone = "eu-west-3a"
  tags = {
    Name = "Amer-subnet-4"
  }
}

#---------------------------------------------------

variable "cidr_blocks_2"  {
  description = "cidr blocks and name tags for vpc and subnet"
  type = list(object({
    cidr_block = string
    name = string
  }))
}

resource "aws_vpc" "dev-vpc-5" {
  cidr_block = var.cidr_blocks_2[0].cidr_block
  tags = {
    Name = var.cidr_blocks_2[0].name  #to Replicate same infrastructure for different environments
  }
}

variable "avail_zone" {}

resource "aws_subnet" "dev-subnet-5" {
  vpc_id = aws_vpc.dev-vpc-5.id
  cidr_block = var.cidr_blocks_2[1].cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name = var.cidr_blocks_2[1].name  #to Replicate same infrastructure for different environments
  }
}
#.\terraform.exe apply -var-file terraform-dev.tfvars -var "avail_zone=eu-west-3a" -auto-approve
#.\terraform.exe destroy -var-file terraform-dev.tfvars -var "avail_zone=eu-west-3a" -auto-approve
#---------------------------------------------------










