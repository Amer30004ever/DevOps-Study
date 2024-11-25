resource "aws_subnet" "ForgTech_subnet" {
    vpc_id = aws_vpc.ForgTech_vpc.id
    cidr_block = "10.0.10.0/24"
    tags = {
        "Environment" = var.tags[0]
        "Owner" = var.tags[1]
    }
}