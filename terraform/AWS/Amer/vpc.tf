resource "aws_vpc" "ForgTech_vpc" {
    cidr_block = "10.10.0.0/16"
    tags = {
        "Environment" = var.tags[0]
        "Owner" = var.tags[1]
    }
}