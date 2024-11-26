resource "aws_dynamodb_table" "backend_db_table" {
    name = "backend_db_table"
    hash_key = "id"
    billing_mode = "PAY_PER_REQUEST"

    attribute {
        name = "id"
        type = "S"
    }
  
}