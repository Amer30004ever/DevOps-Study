# Creates a VPC endpoint in the specified VPC to enable private connectivity to S3
# - vpc_id: Links to the ForgTech VPC
# - service_name: Specifies S3 service in us-east-1 region
# - vpc_endpoint_type: Interface type endpoint which creates an ENI in the VPC
resource "aws_vpc_endpoint" "ForgTech_vpc_endpoint" {
    vpc_id = aws_vpc.ForgTech_vpc.id
    service_name = "com.amazonaws.us-east-1.s3"
    vpc_endpoint_type = "Interface"
}

# Associates the VPC endpoint with a specific subnet to enable access from that subnet
# - vpc_endpoint_id: References the VPC endpoint created above
# - subnet_id: Links to the ForgTech subnet where the endpoint will be accessible
resource "aws_vpc_endpoint_subnet_association" "ForgTech_vpc_endpoint_subnet_association" {
    vpc_endpoint_id = aws_vpc_endpoint.ForgTech_vpc_endpoint.id
    subnet_id = aws_subnet.ForgTech_subnet.id
}
