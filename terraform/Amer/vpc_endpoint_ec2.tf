# AWS VPC Endpoint Resource:
# - Creates a VPC endpoint to privately connect your VPC to AWS EC2 service without going over the internet
# - Increases security by keeping traffic within AWS network
# - Reduces data transfer costs by avoiding internet gateways
# - Improves latency since traffic stays on AWS backbone network
# - Commonly used for secure access to AWS services from private subnets

resource "aws_vpc_endpoint" "ec2" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.us-west-2.ec2"
#  vpc_endpoint_type = "Interface"

/*
  security_group_ids = [
        aws_security_group.sg1.id,
    ]
*/

  #private_dns_enabled = true

/*
  subnet_ids = [
    aws_subnet.subnet1.id,
  ]
*/
}


#2#
# This resource block creates a VPC endpoint for EC2 service
# vpc_id: Links this endpoint to the ForgTech_log_bucket_vpc VPC
# service_name: Specifies the AWS EC2 service in us-east-1 region to connect to
# vpc_endpoint_type: "Interface" creates an elastic network interface with a private IP
# subnet_ids: Places the endpoint in the specified subnet
# security_group_ids: Associates the endpoint with the specified security group
# private_dns_enabled: Enables private DNS for the endpoint
resource "aws_vpc_endpoint" "ec2" {
    vpc_id = aws_vpc.ForgTech_log_bucket_vpc.id
    service_name = "com.amazonaws.us-east-1.ec2"
    vpc_endpoint_type = "Interface"
    subnet_ids = [aws_subnet.ForgTech_log_bucket_subnet.id]
    security_group_ids = [aws_security_group.ForgTech_log_bucket_sg.id]
    private_dns_enabled = true
}


# VPC Endpoint Types:
# 1. Interface Endpoints (vpc_endpoint_type = "Interface"):
#    - Creates an ENI (elastic network interface) with a private IP
#    - Used for services like EC2, SNS, SQS, CloudWatch, etc
#    - Powered by AWS PrivateLink
#    - Costs apply for usage and data processing
#    - Use cases: Private access to AWS services without internet gateway
#
# 2. Gateway Endpoints (vpc_endpoint_type = "Gateway"): 
#    - Target specific route tables
#    - Only supports S3 and DynamoDB
#    - No additional charges
#    - Use cases: Cost-effective private access to S3/DynamoDB
#
# 3. GatewayLoadBalancer Endpoints (vpc_endpoint_type = "GatewayLoadBalancer"):
#    - Used with Gateway Load Balancers
#    - Enables traffic interception through 3rd party appliances
#    - Use cases: Network security, monitoring, traffic inspection