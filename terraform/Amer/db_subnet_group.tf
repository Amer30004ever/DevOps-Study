#db subnet group for rds
resource "aws_db_subnet_group" "ForgTech_subnet_group" {
    name = "subnet-group"
    subnet_ids = [aws_subnet.ForgTech_subnet.id]
}