resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.us-west-2.s3"
  #vpc_endpoint_type = "Gateway"

  #vpc_endpoint_type = "Interface"
 
  #route_table_ids = [aws_route_table.private.id]

/*
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": "*",
        "Action": "*",
        "Resource": "*"
      }
    ]
  })
*/

  tags = {
    Environment = "test"
  }
}