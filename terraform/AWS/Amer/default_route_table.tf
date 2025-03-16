resource "aws_default_route_table" "main-rtb"  {
  default_route_table_id = aws_vpc.app-vpc.default_route_table_id  
  #to get 'default_route_table_id' 
  #.\terraform.exe state show aws_vpc.app-vpc

  route {
    cidr_block = "0.0.0.0/0"
    #gateway_id = aws_internet_gateway.app-igw.id 
  }
  tags = {
    Name = "${var.env_prefix}-main-rtb"
  }
}
