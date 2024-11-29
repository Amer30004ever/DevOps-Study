variable "tags" {
    default = {
        "Environment" = "Test"
        "Owner" = "Amer" 
    }
}

variable "aws_region" {
    default = "us-east-1"
}
variable "vpc_name" {
    default = "vpc-test"
}

variable "cidr_blocks_vpc" { 
    default = "10.0.0.0/16"
    }
variable "cidr_blocks_subnet" { 
    default = "10.0.10.0/24"
    }
variable "availability_zone" {
    default ="eu-central-1b"
    }
variable "env_prefix" { 
    default = "development"
    }
variable "my_ip" { 
    default ="41.234.56.240/32"
    }
variable "instance_type" { 
    default = "t2.micro"
    }
variable "my_publick_key" { 
    default ="C:/Users/MegaStore/.ssh/id_ed25519.pub" #<---this path syntax works too
    } 
variable "my_publick_key_location" {
    default = "C:\\Users\\MegaStore\\.ssh\\id_ed25519.pub" #<---this path syntax works too
} 

variable "transition" {
  type = list(string)
}

variable "bucket_name" {
  type = string
}