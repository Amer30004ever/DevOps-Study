resource "aws_vpc" "ForgTech_vpc" {
    cidr_block = "10.10.0.0/16"
    tags = {
        "Environment" = var.tags[0]
        "Owner" = var.tags[1]
    }
}

resource "aws_subnet" "ForgTech_subnet" {
    vpc_id = aws_vpc.ForgTech_vpc.id
    cidr_block = "10.0.10.0/24"
    tags = {
        "Environment" = var.tags[0]
        "Owner" = var.tags[1]
    }
}

resource "aws_vpc_endpoint" "ForgTech_vpc_endpoint" {
    vpc_id = aws_vpc.ForgTech_vpc.id
    service_name = "com.amazonaws.us-east-1.s3"
    vpc_endpoint_type = "Interface"
}

resource "aws_vpc_endpoint_subnet_association" "ForgTech_vpc_endpoint_subnet_association" {
    vpc_endpoint_id = aws_vpc_endpoint.ForgTech_vpc_endpoint.id
    subnet_id = aws_subnet.ForgTech_subnet.id
}