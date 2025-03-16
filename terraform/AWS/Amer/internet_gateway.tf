# Creates an Internet Gateway resource that enables communication between VPC and the internet
# The Internet Gateway is attached to the specified VPC using vpc_id
resource "aws_internet_gateway" "app-igw" {
  vpc_id = aws_vpc.frontend_vpc.id
  tags = {
        "Owner" = "Amer"
        } 
}

# Creates a route table for the VPC that contains routing rules
# This route table is configured with a route that sends all internet-bound traffic (0.0.0.0/0)
# through the Internet Gateway created above
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.frontend_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app-igw.id
  }

  tags = {
        "Owner" = "Amer"
        }
}

# Associates the route table with a specific subnet
# This makes the subnet public by giving it access to the internet via the route table
resource "aws_route_table_association" "public_rt_association" {
  subnet_id      = aws_subnet.lb_subnet.id
  route_table_id = aws_route_table.public_rt.id
}
