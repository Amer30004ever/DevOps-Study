/*resource "aws_route_table" "myapp-route-table" {
  vpc_id = aws_vpc.app-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app-igw.id
  }
  tags = {
    Name = "${var.env_prefix}-rtb"
  }
}*/

/*resource "aws_route_table_association" "a-rtb-subnet" {
  subnet_id = aws_subnet.app-subnet.id
  route_table_id = aws_route_table.myapp-route-table.id
}*/
