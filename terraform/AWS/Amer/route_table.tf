# This route table resource defines routing rules for the VPC
# - It is associated with the frogtech VPC
# - Contains a default route (0.0.0.0/0) that directs all outbound traffic to the internet gateway
# - Includes standard tags for Name, Environment and Owner

/*resource "aws_route_table" "frogtech-route-table" {
  vpc_id = aws_vpc.frogtech-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.frogtech-igw.id
  }
  tags = {
    Name = "frogtech-route-table"
    Environment = var.Environment[0]
    Owner = var.Environment[1]
  }
}*/

# This resource associates the route table with a specific subnet
# - Links the route table to the frogtech subnet
# - Ensures the subnet uses the routing rules defined in the route table

/*resource "aws_route_table_association" "frogtech-route-association" {
  subnet_id = aws_subnet.frogtech-subnet.id
  route_table_id = aws_route_table.frogtech-route-table.id
}*/
