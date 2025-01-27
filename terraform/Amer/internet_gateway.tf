# This resource creates an Internet Gateway (IGW) in AWS
# An Internet Gateway enables communication between a VPC and the internet
# The IGW is attached to the specified VPC using vpc_id
resource "aws_internet_gateway" "app-igw" {
  vpc_id = aws_vpc.app-vpc.id
  tags = {
        Environment = var.tags.Environment
        Owner = var.tags.Owner
    }
}
